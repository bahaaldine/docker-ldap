LDAP.
================================

[![](https://badge.imagelayers.io/bahaaldine/docker-ldap:latest.svg)](https://imagelayers.io/?images=bahaaldine/docker-ldap:latest 'Get your own badge on imagelayers.io')

## Image description ##

This is a LDAP server used for demoing Elastisearch Shield security plugins.
It comes with a pre-configured base of users & groups: 
 
- The `dn: ou=Users,dc=elastic,dc=co` group : is the ES cluster administrator group
- The `dn: ou=Marvels,dc=elastic,dc=co`group : is the Marvel UI users group
- The `dn: ou=Watcher,dc=elastic,dc=co`group : is the Watcher manager group

## Installation ##

```bash
$ docker pull bahaaldine/docker-ldap
```

## Running as a standalone container ##

```bash
$ docker run -d -p 389:389 --name ldap -t bahaaldine/docker-ldap
```
- 389 : LDAP listening port

## Running as part of a Docker Compose application ##

```lang
ldap1:
  hostname: local.ldap.elastic.co
  image: bahaaldine/docker-ldap
  volumes:
    - "files:/tmp/files"
  ports:
    - "389:389"
```

The volumes section lets you map host directory to container directories, here, the `more.ldif` files
    - front.ldif: allows to add groups to the LDAP
    - more.ldif: allows to add users to the LDAP


## Verify the data inside the ldap database ##

Use `ldapsearch` to check the data, 

    $ docker exec -it ldap bash
	# ldapsearch -H ldap://localhost -LL -b ou=Users,dc=elastic,dc=co -x
	version: 1

	dn: ou=Users,dc=elastic,dc=co
	objectClass: organizationalUnit
	ou: Users

	dn: cn=bahaaldine,ou=Users,dc=elastic,dc=co
    objectclass: inetOrgPerson
    .....

## Important data ##

The admin user/passwd and BaseDN list below

    LDAP username                  : cn=admin,dc=elastic,dc=co
    cn=admin,dc=elastic,dc=co's password : password
    Account BaseDN                 [DC=168,DC=56,DC=153:49154]: ou=Users,dc=elastic,dc=co
    Group BaseDN                   [ou=Users,dc=elastic,dc=co]:


## Customize your own data ##

You can create for your own by checking `files/more.ldif`

    dn: cn=Shay Banon,ou=Users,dc=elastic,dc=co
    objectclass: inetOrgPerson
    cn: Shay Banon
    sn: Banon
    uid: sbanon
    userpassword: ShayBanon
    description: the dude abides
    ou: IT

The file will be added by command

    ldapadd -x -D cn=admin,dc=elastic,dc=co -w password -c -f more.ldif

