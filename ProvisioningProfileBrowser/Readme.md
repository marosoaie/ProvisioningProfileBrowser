#  <#Title#>

Extract public key from cer file:
openssl x509 -inform der -in distribution.cer -pubkey -noout

Extract info from cer file:
openssl x509 -inform der -pubkey -noout -text -in distribution.cer



