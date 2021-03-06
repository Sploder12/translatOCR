from PIL import Image
import sys

from tesserocr import PyTessBaseAPI


def recognize_characters(path_input):

    with PyTessBaseAPI(path=path_input) as api:
        api.SetImageFile('testimg.png')
        print(api.GetUTF8Text())

recognize_characters('C:\\Users\\willoh2023\\Documents\\New folder\\tessdata-master')