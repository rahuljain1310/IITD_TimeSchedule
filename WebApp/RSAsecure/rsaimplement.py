# import Naked
import Crypto
from Crypto.PublicKey import RSA
from Crypto import Random
import sys
import ast
random_generator = Random.new().read
key = RSA.generate(1024, random_generator) #generate pub and priv key

publickey = key.publickey()

encrypted = publickey.encrypt('encrypt this message', 32)
print ('encrypted message:',sys.getsizeof(((encrypted)))) #ciphertext

decrypted = key.decrypt(ast.literal_eval(str(encrypted)))
print ('decrypted', decrypted)