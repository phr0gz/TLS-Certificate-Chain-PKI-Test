#CA Certificate
#openssl genrsa -out CA.key 2048
openssl req -new -nodes -sha256 -keyout CA.key -out CA.csr -extensions v3_ca -subj "/C=EU/ST=SOMEWHERE/L=SOMEWHERE/O=SOMEORG/CN=CA CERTIFICATE" -config <(cat /etc/pki/tls/openssl.cnf)
openssl req -config /etc/pki/tls/openssl.cnf -key CA.key -new -x509 -days 7300 -sha256 -extensions v3_ca -subj "/C=EU/ST=SOMEWHERE/L=SOMEWHERE/O=SOMEORG/CN=CA CERTIFICATE" -out CA.pem

openssl x509 -text -noout -in CA.pem


#Pri Intermediate
openssl req -new -nodes -sha256 -keyout CA_Intermediary_1.key -out CA_Intermediary_1.csr -extensions v3_ca -subj "/C=EU/ST=SOMEWHERE/L=SOMEWHERE/O=SOMEORG/CN=CA INTERMEDIARY CERTIFICATE First" -config /etc/pki/tls/openssl.cnf
openssl x509 -req -days 7300 -sha256 -extfile <(printf "subjectKeyIdentifier = hash\nauthorityKeyIdentifier=keyid:always,issuer\nkeyUsage = critical, digitalSignature, cRLSign, keyCertSign\nbasicConstraints = CA:true") -in CA_Intermediary_1.csr -CA CA.pem -CAkey CA.key -CAcreateserial -out CA_Intermediary_1.crt

openssl x509 -text -noout -in CA_Intermediary_1.crt

#Intermediate
openssl req -new -nodes -sha256 -keyout CA_Intermediary.key -out CA_Intermediary.csr -extensions v3_ca -subj "/C=EU/ST=SOMEWHERE/L=SOMEWHERE/O=SOMEORG/CN=CA INTERMEDIARY CERTIFICATE App" -config /etc/pki/tls/openssl.cnf
openssl x509 -req -days 7300 -sha256 -extfile <(printf "subjectKeyIdentifier = hash\nauthorityKeyIdentifier=keyid:always,issuer\nkeyUsage = critical, digitalSignature, cRLSign, keyCertSign\nbasicConstraints = CA:true") -in CA_Intermediary.csr -CA CA_Intermediary_1.crt -CAkey CA_Intermediary_1.key -CAcreateserial -out CA_Intermediary.crt


openssl x509 -text -noout -in CA_Intermediary.crt

#Serv1 cert

openssl req -new -nodes -sha256 -keyout ServerCert1_signedByCAIntermediary.key -out ServerCert1_signedByCAIntermediary.csr -extensions v3_req -subj "/C=EU/ST=SOMEWHERE/L=SOMEWHERE/O=SOMEORG/CN=syslog1.test.lab" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:syslog1.test.lab,DNS:syslog1.test.lab"))
openssl x509 -req -days 730 -sha256 -extfile <(printf "subjectAltName=DNS:syslog1.test.lab,DNS:syslog1.test.lab") -in ServerCert1_signedByCAIntermediary.csr -CA CA_Intermediary.crt -CAkey CA_Intermediary.key -CAcreateserial -out ServerCert1_signedByCAIntermediary.crt
openssl x509 -text -noout -in ServerCert1_signedByCAIntermediary.crt

#Serv2 cert
openssl req -new -nodes -sha256 -keyout ServerCert2_signedByCAIntermediary.key -out ServerCert2_signedByCAIntermediary.csr -extensions v3_req -subj "/C=EU/ST=SOMEWHERE/L=SOMEWHERE/O=SOMEORG/CN=syslog2.test.lab" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:syslog2.test.lab,DNS:syslog2.test.lab"))
openssl x509 -req -days 730 -sha256 -extfile <(printf "subjectAltName=DNS:syslog2.test.lab,DNS:syslog2.test.lab") -in ServerCert2_signedByCAIntermediary.csr -CA CA_Intermediary.crt -CAkey CA_Intermediary.key -CAcreateserial -out ServerCert2_signedByCAIntermediary.crt
openssl x509 -text -noout -in ServerCert2_signedByCAIntermediary.crt
