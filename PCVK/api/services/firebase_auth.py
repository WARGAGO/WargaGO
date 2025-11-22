"""
Firebase Authentication middleware and utilities
"""

from typing import Optional
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin
from firebase_admin import credentials, auth, firestore

from api.configs.azure_config import FIREBASE_CREDENTIALS, validate_firebase_config


class FirebaseAuth:
    """Firebase authentication service"""

    def __init__(self):
        """Initialize Firebase Admin SDK"""
        self.enabled = validate_firebase_config()

        if not self.enabled:
            print("Firebase Authentication is disabled due to missing configuration")
            return

        try:
            # Initialize Firebase Admin SDK
            cred = credentials.Certificate(FIREBASE_CREDENTIALS)
            firebase_admin.initialize_app(cred)
            
            # Initialize Firestore client
            self.db = firestore.client()

            print("Firebase Authentication initialized")
            self.enabled = True

        except Exception as e:
            print(f"Error initializing Firebase: {e}")
            self.enabled = False
            self.db = None

    def verify_token(self, token: str) -> Optional[dict]:
        """
        Verify Firebase ID token

        Args:
            token: Firebase ID token

        Returns:
            Decoded token (user info) or None if invalid
        """
        if not self.enabled:
            # If Firebase is disabled, return mock user for development
            print("WARNING: Firebase is disabled, using mock authentication")
            return {
                "uid": "mock-user-id",
                "email": "mock@example.com",
                "email_verified": True,
            }

        try:
            # Verify the token
            decoded_token = auth.verify_id_token(token)
            return decoded_token

        except auth.InvalidIdTokenError:
            print("Invalid Firebase token")
            return None
        except auth.ExpiredIdTokenError:
            print("Expired Firebase token")
            return None
        except Exception as e:
            print(f"Error verifying Firebase token: {e}")
            return None

    def get_user_role(self, uid: str) -> Optional[str]:
        """
        Get user role from Firestore

        Args:
            uid: User ID

        Returns:
            User role (e.g., 'admin', 'user') or None if not found
        """
        if not self.enabled or not self.db:
            return None

        try:
            # Get user document from Firestore
            user_ref = self.db.collection('users').document(uid)
            user_doc = user_ref.get()
            
            if user_doc.exists:
                user_data = user_doc.to_dict()
                return user_data.get('role', 'user')
            else:
                # Default role if user document doesn't exist
                return 'user'

        except Exception as e:
            print(f"Error getting user role: {e}")
            return None

    def get_user_info(self, uid: str) -> Optional[dict]:
        """
        Get user information from Firebase

        Args:
            uid: User ID

        Returns:
            User information or None if not found
        """
        if not self.enabled:
            return None

        try:
            user = auth.get_user(uid)
            return {
                "uid": user.uid,
                "email": user.email,
                "email_verified": user.email_verified,
                "display_name": user.display_name,
                "photo_url": user.photo_url,
                "disabled": user.disabled,
                "created_at": user.user_metadata.creation_timestamp,
                "last_sign_in": user.user_metadata.last_sign_in_timestamp,
            }

        except Exception as e:
            print(f"Error getting user info: {e}")
            return None


# Global instance
firebase_auth = FirebaseAuth()

# Security scheme
security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security),
) -> dict:
    """
    Dependency to get current authenticated user

    Args:
        credentials: HTTP Bearer token from request

    Returns:
        User information from decoded token

    Raises:
        HTTPException: If token is invalid or missing
    """
    if not credentials:
        raise HTTPException(
            status_code=401,
            detail="Missing authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials
    user_info = firebase_auth.verify_token(token)

    if not user_info:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user_info
