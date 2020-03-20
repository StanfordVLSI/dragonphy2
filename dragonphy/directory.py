import os

class Directory:
    @staticmethod
    def path():
        return os.environ['PHY_BUILD_PATH']

