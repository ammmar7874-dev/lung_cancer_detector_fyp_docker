# This file is required for PythonAnywhere (which uses WSGI)
# to run FastAPI (which uses ASGI).

from main import app
from a2wsgi import ASGIMiddleware

# Create a WSGI application from the ASGI app
application = ASGIMiddleware(app)
