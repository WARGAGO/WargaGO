"""
Main FastAPI application
"""

from dotenv import load_dotenv
load_dotenv()

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import gradio as gr

from api.configs.config import (
    API_TITLE,
    API_DESCRIPTION,
    API_VERSION,
    CORS_ORIGINS,
    CORS_CREDENTIALS,
    CORS_METHODS,
    CORS_HEADERS
)
from api.configs.pcvk_config import DEVICE
from api.routes.pcvk_route import router
from api.routes.storage_public_route import public_storage_router
from api.routes.storage_private_route import private_storage_router
from api.services.classification.gradio_interface import create_gradio_interface
from api.services.classification.model_loader import model_manager


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan context manager for startup and shutdown events
    """
    # Startup
    print("=" * 60)
    print(f"Starting {API_TITLE}")
    print(f"Device: {DEVICE}")
    print("=" * 60)
    
    success = model_manager.load_all_models()
    
    if not success:
        print("WARNING: No models were loaded!")
    else:
        loaded_models = model_manager.get_loaded_models()
        print(f"Successfully loaded {len(loaded_models)} model(s): {loaded_models}")
    
    print("=" * 60)
    
    yield
    
    # Shutdown
    print("Shutting down API...")


def create_app() -> FastAPI:
    """
    Create and configure FastAPI application
    
    Returns:
        Configured FastAPI application
    """
    # Initialize FastAPI app with lifespan
    app = FastAPI(
        title=API_TITLE,
        description=API_DESCRIPTION,
        version=API_VERSION,
        lifespan=lifespan
    )
    
    # Add CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=CORS_ORIGINS,
        allow_credentials=CORS_CREDENTIALS,
        allow_methods=CORS_METHODS,
        allow_headers=CORS_HEADERS,
    )
    
    app.include_router(router, prefix="/api")
    app.include_router(public_storage_router, prefix="/api")
    app.include_router(private_storage_router, prefix="/api")
    
    # Create and mount Gradio app at root
    gradio_app = create_gradio_interface()
    app = gr.mount_gradio_app(app, gradio_app, path="/")
    
    return app


# Create app instance
app = create_app()
