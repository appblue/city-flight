import struct
import sys

class Frame:
    def __init__(self, frame_number):
        self.frame_number = frame_number
        self.lines = []
        self.stats = {}
        self.screen_width = 320
        self.screen_height = 256

    def add_line_coordinates(self, x1, y1, x2, y2):
        self.lines.append((x1, y1, x2, y2))

        # update line statistics
        line_weight = max(abs(x1 - x2), abs(y1 - y2))
        self.stats[line_weight] = self.stats.get(line_weight, 0) + 1

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
            if y1<y2:
                ((x1,y1),(x2,y2)) = ((x2,y2),(x1,y1))
            result += struct.pack(">BBBB", x1, y1, x2, y2)
        return result

    def get_stats(self):
        return self.stats


class Scene:
    def __init__(self, file_name):
        self.file_name = file_name
        self.frames = []
        self.stats = {}

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

    def print_statistics(self):
        total_lines = 0
        for frame in self.frames:
            for weight in frame.get_stats().keys():
                self.stats[weight] = self.stats.get(weight, 0) + frame.stats[weight]
                total_lines += frame.stats[weight]
        for i in sorted(self.stats.items(), key=lambda kv: kv[1]):
            print("%4d: %4d" % (i[0], i[1]))
        print("TOTAL LINE: %4d" % total_lines)

    def export(self, export_file_name):
        with open(export_file_name, mode="wb") as f:
            f.write(struct.pack(">H", len(self.frames)))
            for frame in self.frames:
                bin_frame = frame.export_old()
                f.write(bin_frame)


if __name__ == '__main__':
    program_name = sys.argv[0]
    arguments = sys.argv[1:]
    count = len(arguments)

    if count == 1:
        scene = Scene(arguments[0])
        scene.parse()
        scene.export(arguments[0] + ".dat")
        scene.print_statistics()
    else:
        print("""
        USAGE: %s <file_name>        
        """ % program_name)
