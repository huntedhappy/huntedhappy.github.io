openssl genrsa -out ca.key 4096

openssl rand -writerand /root/.rnd

openssl req -x509 -new -nodes -sha512 -days 3650 \
  -subj "/C=CN/ST=Seoul/L=Seoul/O=example/OU=Personal/CN=jenkins.tkg.io" \
  -key ca.key \
  -out ca.crt

openssl genrsa -out yourdomain.com.key 4096

openssl req -sha512 -new \
  -subj "/C=CN/ST=Seoul/L=Seoul/O=example/OU=Personal/CN=jenkins.tkg.io" \
  -key yourdomain.com.key \
  -out yourdomain.com.csr

cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
EOF

openssl x509 -req -sha512 -days 3650 \
  -extfile v3.ext \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -in yourdomain.com.csr \
  -out yourdomain.com.crt

openssl x509 -inform PEM -in yourdomain.com.crt -out yourdomain.com.cert