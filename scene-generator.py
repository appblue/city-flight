N = 5
dl = 0.2
br = 0.3
max_size = ((N - 1) * br + dl) / 2.0

p = [
    (0.0, 0.0, 0.0),
    (dl, 0.0, 0.0),
    (dl, 0.0, dl),
    (0.0, 0.0, dl),
    (0.0, dl, 0.0),
    (dl, dl, 0.0),
    (dl, dl, dl),
    (0.0, dl, dl)
]

v = [
    [0, 4, 5, 1],
    [1, 5, 6, 2],
    [4, 7, 6, 5],
    [2, 6, 7, 3],
    [0, 3, 7, 4],
    [0, 1, 2, 3]
]


def p_add(l, v):
    w = []
    for i in l:
        w.append((i[0] + v[0], i[1] + v[1], i[2] + v[2]))
    return w


def v_add(v, n):
    w = []
    for i in v:
        ww = []
        for j in i:
            ww.append(j + n)
        w.append(ww)
    return w


p_wyn = []
v_wyn = []
ind = 0
for x in range(0, N):
    for y in range(0, N):
        for z in range(0, N):
            p_wyn = p_wyn + p_add(p, (br * x, br * y, br * z))
            v_wyn = v_wyn + v_add(v, ind * 8)
            ind += 1

f = open("model/out.ply", "w")
print("""\
ply
format ascii 1.0           { ascii/binary, format version number }
comment made by Greg Turk  { comments keyword specified, like all lines }
comment this file is a cube
element vertex %d           { define "vertex" element, 8 of them in file }
property float x           { vertex contains float "x" coordinate }
property float y           { y coordinate is also a vertex property }
property float z           { z coordinate, too }
element face %d             { there are 6 "face" elements in the file }
property list uchar int vertex_index { "vertex_indices" is a list of ints }
end_header                 { delimits the end of the header }\
""" % (8 * N * N * N, 6 * N * N * N), file=f)
for i in p_wyn:
    print(i[0] - max_size, i[1] - max_size, i[2] - max_size, file=f)
for i in v_wyn:
    print(len(i), end=' ', file=f)
    for j in i:
        print(j, end=' ', file=f)
    print(file=f)
f.close()
