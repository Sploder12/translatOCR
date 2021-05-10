# Web App translating thing

### Web app portion of the translator

## So far:
- [x] Live webcam streaming to webpage
- [x] Button to grab frame from webcam
- [x] Drag and Drop to webpage
- [X] Make option to use either camera or drag and drop (Homepage)
- [X] Find text from either image or camera (buggy)
- [X] Translating (needs to fix the language selector)
- [ ] Make better looking UI

## Dependencies:
* Python 3

* Flask (flask, flask_dropzone, flask_uploads)

* OpenCV (opencv-contrib-python)

* NumPy

* imutils

You can install all of the dependencies using:
```
pip install -r requirements.txt
```
(`requirements.txt` is located in the root of the repository)

## Fix for flask_uploads werkzeug error:
There is an issue in the flask_uploads package due to werkzeug updating but not flask_uploads and to fix it you need to change one line in `flask_uploads.py`
which should be loacted in:

`C:\Users\<USERNAME>\AppData\Local\Programs\Python\Python39\Lib\site-packages` or on linux,
`~/.local/lib/python3.9/site-packages` unless manually changed


In `flask_uploads.py` on line 26 Change:
```
from werkzeug import secure_filename,FileStorage
```
To:
```
from werkzeug.utils import secure_filename
from werkzeug.datastructures import  FileStorage
```
