import struct


class Frame:
    def __init__(self, frame_number):
        self.frame_number = frame_number
        self.lines = []
        self.screen_width = 320
        self.screen_height = 256

    def add_line_coordinates(self, x1, y1, x2, y2):
        self.lines.append((x1, y1, x2, y2))

    def add_line(self, data):
        (x1, y1, x2, y2) = map((lambda x: int(x)), data.split(','))
        self.add_line_coordinates(x1, y1, x2, y2)

    def export(self):
        result = struct.pack('>H', len(self.lines))
        for (x1, y1, x2, y2) in self.lines:
            address = int(y1 * self.screen_width / 2) + int(x1 / 16)
            result += struct.pack(">HHhh", address, x1, x2 - x1, y2 - y1)
        return result

    def export_old(self):
        result = struct.pack('>H', len(self.lines))
        for (x1, y1, x2, y2) in self.lines:
            address = int(y1 * self.screen_width / 2) + int(x1 / 16)
            result += struct.pack(">HHHH", x1, y1, x2, y2)
        return result


class Parser:
    def __init__(self, file_name):
        self.file_name = file_name
        self.frames = []

    def parse(self):
        current_frame = None
        with open(self.file_name) as f:
            lines = f.readlines()
            for lin in lines:
                (element, data) = lin.rstrip().lower().split(':')
                if element.startswith("frame"):
                    current_frame = Frame(int(data))
                    self.frames.append(current_frame)
                elif element.startswith("line"):
                    current_frame.add_line(data)

    def export(self, export_file_name):
        with open(export_file_name, mode="wb") as f:
            f.write(struct.pack(">H", len(self.frames)))
            for frame in self.frames:
                bin_frame = frame.export_old()
                f.write(bin_frame)

if __name__ == '__main__':
    p = Parser("lines.txt")
    p.parse()
    p.export("test.dat")
