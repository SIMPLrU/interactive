#!/bin/sh

#http PUT "https://dev-513727-admin.okta.com/oauth2/v1/clients/0oa4giun5hZXCeaQB357" Authorization:SSWS\ 00wuBqKCAd9F8crLG3NXDB2P2FleKUADL8o8tBLdCv < body.json


http PUT "https://dev-513727-admin.okta.com/api/v1/apps/0oa4giun5hZXCeaQB357" Authorization:SSWS\ 00wuBqKCAd9F8crLG3NXDB2P2FleKUADL8o8tBLdCv < app.json
