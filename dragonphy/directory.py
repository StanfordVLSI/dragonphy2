from pathlib import Path

class Directory:
    @staticmethod
    def path():
        return str(Path(__file__).parents[1])
