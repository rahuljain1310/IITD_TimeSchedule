# import Naked
import Crypto
from Crypto.PublicKey import RSA
from Crypto import Random
import sys
import ast
random_generator = Random.new().read
key = RSA.generate(1024, random_generator) #generate pub and priv key
private_key = open("privatekey.pem",'w')
private_key.write(key.exportKey())
private_key.close()
public_key = open("public_key.pem",'w')
public_key.write(key.publickey().exportKey())
public_key.close()
publickey = key.publickey()

encrypted = publickey.encrypt('encrypt this message', 32)
print ('encrypted message:',sys.getsizeof(((encrypted)))) #ciphertext

decrypted = key.decrypt(ast.literal_eval(str(encrypted)))
print ('decrypted', decrypted)