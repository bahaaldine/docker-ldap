Elasticsearch Shield + LDAP Demo.
===================================

## Introduction ##

This Docker Compose project is an application which intend to demonstrate
the integration between Elasticsearch Shield security plugin and a LDAP server.

## Running the application ##

In the example folder, use Docker Compose to launch the application: 

```bash
docker-compose up

```

## LDAP Users and Groups ##

This application is using the users and groups present by default in the LDAP.

### Groups ###

The DN template used to designate all groups is:

    `ou={GROUP_NAME},dc=elastic,dc=co`

There are 3 groups : Users, Marvels and Watcher

### Users ###

The DN template used to designate all users is:

    `cn={USER_NAME},ou={GROUP_NAME},dc=elastic,dc=co`

Here is the list of users splitted by groups:

- Users:
    - bahaaldine / bazarim
    - morgan / mgoeller
    - steve / smayzak
    - dimitri / dmarx
    - matias / mcascallares

- Marvels
    - alan / ahardy
    - christoph / cwurm
    - david / derickson
    - agent / amarvel

- Watchers
    - antoine / agirbal
    - catherine / cjohnson
    - christian / cdahlqvist
    - jeremy / jhorton
    - peter / pkim

The LDAP admin user has the following credentials:

DN: cn=admin,dc=elastic,dc=co
user : admin
password:  password

### Network configuration ###

The LDAP server is listening on port 389

## Elasticsearch configuration ##

### shield *.yml files ###

#### roles.yml

A list of existing roles are shipped out of the box with Shield, but some of them 
are missing and should be added to the roles.yml file, such as the followings:

```lang
# Marvel role, allowing all operations
# on the marvel indices
marvel_user:
  cluster: cluster:monitor/nodes/info, cluster:admin/plugin/license/get
  indices:
    '.marvel-*': all

# Marvel Agent users
marvel_agent:
  cluster: indices:admin/template/get, indices:admin/template/put
  indices:
    '.marvel-*': indices:data/write/bulk, create_index

watcher_admin:
    cluster: manage_watcher
```

- marvel_user: intend to be used to access Marvel UI.
- marvel_agent: is dedicated to create and write data in the marvel index.
- watcher_admin: is the role used to manage watcher.

#### role_mapping.yml 

The role mapping file map the LDAP users/groups to the Shield roles:

```lang
admin:
  cluster: all
  indices:
    '*': all

admin:
  - "cn=bahaaldine,ou=Users,dc=elastic,dc=co"
  ...

marvel_user:
  - "cn=alan,ou=Marvels,dc=elastic,dc=co"
  ...

marvel_agent:
  - "cn=agent,ou=Marvels,dc=elastic,dc=co"

watcher_admin:
  - "cn=antoine,ou=Watchers,dc=elastic,dc=co"
```

### elasticsearch.yml ###

#### shield configuration ####

Elasticsearch Shield configuration is based on the following documentation [link](https://www.elastic.co/guide/en/shield/current/ldap.html#_ldap_realm_with_user_dn_templates)

```lang
shield:
  authc:
    realms:
      ldap1:
        type: ldap
        order: 0
        url: "ldap://URL_TO_LDAP:389"
        user_dn_templates:
          - "cn={0},dc=elastic,dc=co"
          - "cn={0},ou=Users,dc=elastic,dc=co"
          - "cn={0},ou=Marvels,dc=elastic,dc=co"
          - "cn={0},ou=Watchers,dc=elastic,dc=co"
        group_search:
          base_dn: "ou=Users,dc=elastic,dc=co"
        files:
          role_mapping: "/etc/elasticsearch/shield/role_mapping.yml"
        unmapped_groups_as_roles: false
```
The elasticsearch node points to the LDAP server,
and uses the DN template configuration to retreive users and groups.
It also refers to the role_mapping under Elasticsearch shield configuration directory.

So whenever a request is made, Elasticsearch fetch the user based on the DN template from LDAP to authenticate
and retreive the role mapping from the *.yml file.

#### marvel configuration ####

The marvel agent needs to be configured in order to use the related LDAP user credential,
otherwise any operation on the marvel index would fail.

```lang
marvel:
  agent:
    exporter:
      es:
        hosts: [ "http://agent:amarvel@localhost:9200" ]
```

#### watcher configuration ####

This example includes watcher as well and a configuration in order
to push result of an alert by email:

```lang
watcher.actions.email.service.account:
  work:
    profile: gmail
    email_defaults:
      from: FROM_EMAIL_ADDRESS
    smtp:
      auth: true
      starttls.enable: true
      host: EMAIL_SERVER
      port: EMAIL_PORT
      user: EMAIL_ACCOUNT_USERNAME
      password: EMAIL_ACCOUNT_PASSWORD
```

The following values should be replaced by actual values:
- FROM_EMAIL_ADDRESS: the email address from which the alert is sent
- EMAIL_SERVER: the email server hostname
- EMAIL_PORT: the email server port
- EMAIL_ACCOUNT_USERNAME: email account username
- EMAIL_ACCOUNT_PASSWORD: email account password