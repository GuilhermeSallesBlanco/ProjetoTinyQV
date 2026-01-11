import gzip
import urllib.request
import gzip
import pathlib
import sys
import inspect
import functools
import operator
import json

import numpy as np

RESETC = "\033[39m\033[49m"
GREEN = "\033[38;2;44;160;44m"
RED = "\033[38;2;214;39;40m"

def display_image(dat, size=(28, 28)):
    """Expects uint8 data"""
    def bg(gs): return f"\033[48;2;{gs};{gs};{gs}m"
    def fg(gs): return f"\033[38;2;{gs};{gs};{gs}m"
    num_rows, num_cols = size
    for i in range(0, num_rows, 2):
        print("".join(f"{fg(int(dat[i * num_cols + j]))}{bg(int(dat[(i + 1) * num_cols + j]))}▀" for j in range(num_cols)) + RESETC)

def display_outputs(output, expected):
    assert all(-8 <= x <= 7 for x in output)
    def bar(x, color=""): return color + "▄" * (x + 9) + RESETC + f" {x}"
    actual = np.argmax(output)
    for i, x in enumerate(output):
        print(f"{i}▕ {bar(x, color=GREEN if i == expected else (RED if i == actual else ''))}")

def resize_interp(in_size, out_size, half_pixel_centers=False):
    offset = 0.5 if half_pixel_centers else 0.
    pos = ((np.arange(out_size) + offset) * in_size / out_size - offset).astype(np.float32)
    lower = np.floor(pos)
    upper = np.minimum(lower.astype(int) + 1, in_size - 1)
    lerp = pos - lower
    return np.maximum(lower, 0).astype(int), upper, lerp

def resize_bilinear(x, out_h, out_w, half_pixel_centers=False):
    assert x.ndim == 3, "expects array of shape (B, H, W)"
    in_h, in_w = x.shape[1:]
    left, right, x_lerp = resize_interp(in_w, out_w, half_pixel_centers=half_pixel_centers)
    top, bot, y_lerp = resize_interp(in_h, out_h, half_pixel_centers=half_pixel_centers)

    top_left = x[:, top[..., None], left[None]]
    top_right = x[:, top[..., None], right[None]]
    top = top_left + (top_right - top_left) * x_lerp

    bot_left = x[:, bot[..., None], left[None]]
    bot_right = x[:, bot[..., None], right[None]]
    bot = bot_left + (bot_right - bot_left) * x_lerp

    output = top + (bot - top) * y_lerp[..., None]
    return output

class tqdm:
    def __init__(self, iterable=None, pbar_length=20, desc="", total=None, display=True):
        self.desc, self.pbar_length, self.i, self.total, self.display = desc, pbar_length, 0, total or len(iterable), display
        self.iterable = iterable
    def __iter__(self):
        for item in self.iterable:
          yield item
          self.update(1)
        self.update(close=True)
    def update(self, c=0, close=False):
        self.i += c
        percent = min(100, self.i * 100 // self.total)
        filled = int(self.pbar_length * percent // 100)
        if self.display:
            print(f"\r{self.desc} [{'▰' * filled + '▱' * (self.pbar_length - filled)}] {percent}%", end='\n'*close, flush=True, file=sys.stderr)

def fetch(url, fn=None, dstdir=None, pbar_width=20):
    fp = pathlib.Path(fn if fn is not None else pathlib.Path(url).name)
    if dstdir is not None: fp = pathlib.Path(dstdir) / fp
    if fp.is_file(): return fp
    with urllib.request.urlopen(url) as r, open(fp, 'wb') as f:
        assert r.status == 200, r.status
        pbar = tqdm(total=int(r.headers.get('content-length', 0)), desc=f"Downloading {fp}")
        while chunk := r.read(16384): pbar.update(f.write(chunk))
        pbar.update(close=True)
    return fp

def fetch_mnist(datadir="data"):
    base_url = "https://storage.googleapis.com/cvdf-datasets/mnist/"
    def parse(file): return np.frombuffer(gzip.open(file).read(), dtype=np.uint8).copy()
    (basedir := pathlib.Path(datadir)).mkdir(parents=True, exist_ok=True)
    x_train = parse(fetch(f"{base_url}train-images-idx3-ubyte.gz", dstdir=basedir))[16:].reshape(-1, 784)
    y_train = parse(fetch(f"{base_url}train-labels-idx1-ubyte.gz", dstdir=basedir))[8:]
    x_test = parse(fetch(f"{base_url}t10k-images-idx3-ubyte.gz", dstdir=basedir))[16:].reshape(-1, 784)
    y_test = parse(fetch(f"{base_url}t10k-labels-idx1-ubyte.gz", dstdir=basedir))[8:]
    return x_train, y_train, x_test, y_test

def packed(vals, width):
    return functools.reduce(operator.or_, map(lambda x: (x[1] & ((1 << width) - 1)) << x[0] * width, enumerate(vals)))

def unpacked(v, width, gran): return [(v >> i * gran) & ((1 << gran) - 1) for i in range(-(-width // gran))]

def as_signed(vals, width): return [(v + (1 << width - 1)) % (1 << width) - (1 << width - 1) for v in vals]

def prod(lst): return functools.reduce(lambda x, y: x * y, lst)

def tiled(x, *tile_shape):
    assert len(x.shape) == len(tile_shape)
    r, c = x.shape
    cblocks = -(-c // tile_shape[1])
    rblocks = -(-r // tile_shape[0])
    y = np.pad(x, ((0, rblocks * tile_shape[0] - r), (0, cblocks * tile_shape[1] - c)))
    return np.transpose(y.reshape(rblocks, tile_shape[0], cblocks, tile_shape[1]), (0, 2, 1, 3))

def dtype_to_bounds(width, signed): return (-1 << width - 1, (1 << width - 1) - 1) if signed else (0, (1 << width) - 1)

def qfc(input, weight, bias, output_zp, qmul, shamt, relu=True, width=4, signed=True):
    out = input.astype(np.int16) @ weight.astype(np.int16) + bias.astype(np.int16)
    out = np.maximum(out, 0) if relu else out
    out = (qmul.astype(np.int32) * out >> shamt) + output_zp
    return np.clip(out, *dtype_to_bounds(width, signed)).astype(np.int8)

class NumpyModel:
    def __init__(self, modelfn, tensorfn, width=4):
        self.width = width
        with open(modelfn) as fm, open(tensorfn, 'rb') as ft:
            self.ops = json.load(fm)
            self.tensors = ft.read()
        self.layers = [self._parse_op(op) for op in self.ops]

    def __call__(self, x: np.ndarray):
        return functools.reduce(lambda x, f: f(x), self.layers, x)

    def _parse_op(self, op):
        match op["op"]:
            case "fully_connected":
                qparams = {k: np.array(v) for k, v in op["qparams"].items()}
                tensors = {k: self._extract_tensor(v)  for k, v in op["args"].items()}
                return functools.partial(qfc, **tensors, **qparams, relu=op["act"] == "RELU", width=self.width)
            case "reshape":
                return lambda x: x.reshape(op["args"]["shape"])

    def _extract_tensor(self, info):
        dtype = np.dtype(info["dtype"])
        return np.frombuffer(self.tensors[info["offset"]:info["offset"] + prod(info["shape"]) * dtype.itemsize], dtype=dtype).reshape(info["shape"])

async def tb_qfc(tqv, input, weight, bias, output_zp, qmul, shamt,
    relu=True, width=4, acc_width=16, acc_depth=1, nrows=2, ncols=2, min_shamt=0, shamt_width=5, progress=True):
    assert (qmul < 1 << acc_width - 1).all() 
    assert (shamt >= min_shamt).all() and (shamt < (1 << shamt_width) - 1).all()
    assert nrows * width * (ncols + 1) <= 32, "weights and activations tile rows don't fit in the bus"
    assert acc_width * ncols <=  32, "bias tile row doesn't fit in the bus"

    m, k = input.shape
    _, n = weight.shape

    tiled_w = tiled(weight, nrows, ncols)
    tiled_inp = tiled(input, acc_depth, nrows)
    pbar = tqdm(total=m * n, desc=f"fully connected {k, n}, B={m}", display=progress)

    await tqv.write_byte_reg(0x10, (output_zp & 0xF) << 1 | relu)

    result = []
    for nn in range(tiled_w.shape[1]):
        # write quantized multipliers and shift amounts
        await tqv.write_byte_reg(0x04, packed(shamt[nn * ncols: (nn + 1) * ncols].tolist(), shamt_width))
        await tqv.write_hword_reg(0x08, packed(qmul[nn * ncols: (nn + 1) * ncols].tolist(), acc_width - 1))

        for mm in range(tiled_inp.shape[0]):
            # reset accumulator with bias
            await tqv.write_hword_reg(0x02, packed(bias[nn * ncols:(nn + 1) * ncols].tolist(), acc_width))

            for kk in range(tiled_inp.shape[1]):
                # send weights and inputs
                packed_inputs = packed([v for row in tiled_inp[mm, kk].tolist() for v in row], width)
                packed_weights = packed([v for row in tiled_w[kk, nn].tolist() for v in row], width)
                await tqv.write_word_reg(0x01, packed_weights << nrows * width | packed_inputs)

            # read scaled accs
            result.append(as_signed(unpacked(await tqv.read_byte_reg(0x02), width * ncols, width), width))
            pbar.update(acc_depth * ncols)
    pbar.update(close=True)
    return np.array(result, dtype=np.int8).reshape(-1, m, ncols).transpose(1, 0, 2).reshape(m, n)

class CocotbModel:
    def __init__(self, tqv, modelfn, tensorfn, nrows=4, ncols=1, width=4, acc_width=32):
        self.tqv = tqv
        self.nrows, self.ncols, self.width, self.acc_width = nrows, ncols, width, acc_width
        with open(modelfn) as fm, open(tensorfn, 'rb') as ft:
            self.ops = json.load(fm)
            self.tensors = ft.read()
        self.layers = [self._parse_op(op) for op in self.ops]

    async def __call__(self, x: np.ndarray):
        for l in self.layers:
            x = await l(x) if inspect.iscoroutinefunction(l) else l(x)
        return x

    def _parse_op(self, op):
        match op["op"]:
            case "fully_connected":
                qparams = {k: np.array(v) if isinstance(v, list) else v for k, v in op["qparams"].items()}
                tensors = {k: self._extract_tensor(v)  for k, v in op["args"].items()}
                return functools.partial(tb_qfc, self.tqv, **tensors, **qparams, relu=op["act"] == "RELU",
                    width=self.width, acc_width=self.acc_width, nrows=self.nrows, ncols=self.ncols)
            case "reshape":
                return lambda x: x.reshape(op["args"]["shape"])

    def _extract_tensor(self, info):
        dtype = np.dtype(info["dtype"])
        return np.frombuffer(self.tensors[info["offset"]:info["offset"] + prod(info["shape"]) * dtype.itemsize], dtype=dtype).reshape(info["shape"])
