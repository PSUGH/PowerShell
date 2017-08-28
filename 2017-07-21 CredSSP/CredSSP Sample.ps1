#test access to file share -> fail
invoke-command { dir \\fileserver\devtools } -computer appserver01 -authentication credssp -credential domain\user

#enable server role on source server
Enable-WSManCredSSP -Role Server

#enable client role on delegating server
#set-item wsman:localhost\client\trustedhosts -value *
Enable-WSManCredSSP -Role Client –DelegateComputer *

#test access to file share -> success
invoke-command { dir \\fileserver\devtools } -computer appserver01 -authentication credssp -credential domain\user
