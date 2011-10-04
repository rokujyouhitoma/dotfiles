# -*- coding: utf-8 -*-
from flask import Flask
from beaker.middleware import SessionMiddleware

settings = {
    'DEBUG': True,
    'STATIC_PATH': '/static'
}
app = Flask(__name__, settings)
app.debug = True
app.secret_key = 'A0Zr98j/3yX R~XHH!jmN]LWX/,?RT'

# http://flask.pocoo.org/snippets/61/
# http://beaker.groovie.org/configuration.html#options-for-sessions-and-caching
session_opts = {
    'session.type': 'ext:database',
    'session.url': 'sqlite:///beaker.db',
    'session.lock_dir': 'beaker.lock',
}
app.wsgi_app = SessionMiddleware(app.wsgi_app, session_opts)
