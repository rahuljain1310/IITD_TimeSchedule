import Crypto
from Crypto.PublicKey import RSA
from Crypto import Random
from Crypto.Cipher import PKCS1_OAEP
from Crypto.Hash import SHA256
from base64 import b64decode
import sys
import ast
key =RSA.importKey('privatekey.pem')
cipher = PKCS1_OAEP.new(key, hashAlgo=SHA256)
decrypted_message = cipher.decrypt(b64decode())