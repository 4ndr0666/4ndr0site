####################### Chmod ################################

Read by owner - 400
Write by owner - 200
Execute by owner - 100
```
Read by group - 040
Write by group - 020
Execute by group - 010
```
Read by others - 004
Write by others - 002
Execute by others - 001
```

## Some common examples:

$ chmod 751 (allows you +rwx, your group +rx, and everyone else +x)
```
$ chmod 700 (allows +rwx to only yourself)
```
$ chmod 744 (allows +wx to owner of file, +r to everyone else)
```
$ chmod 755 (allows you +rwx, others only +rx)
```
$ chmod 711 (allows you +rwx, others +x)
```
$ chmod 644 (allows you +rw, others +r)
```


