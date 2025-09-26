# backend/asgi.py
import os
from django.core.asgi import get_asgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')

app = get_asgi_application() # 👈 Corrected variable name