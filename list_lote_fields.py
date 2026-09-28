import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("service_account.json") # We might not have this, or we could just run a dart script
