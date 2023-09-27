## Generate GPG Key
gpg --full-gen-key
```

## List private gpg key
gpg --list-secret-keys --keyid-format LONG [EMAIL]

Identify the sec line, and copy the GPG key ID. It begins after 
the / character. In this example, the key ID is 30F2B65B9246B6CA:

sec   rsa4096/30F2B65B9246B6CA 2017-08-18 [SC]
      D5E4F29F3275DC0CDA8FFC8730F2B65B9246B6CA
uid                   [ultimate] Mr. Robot <your_email>
ssb   rsa4096/B7ABC0813E4028C0 2017-08-18 [E]
```

## Show the associated pub key
$gpg --armor --export <ID> 
```

## Nvchad download link
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
```

