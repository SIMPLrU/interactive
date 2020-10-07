# kong-plugin-mocking

Mock your services on the go using Kong Mocking Plugin. This plugins reads the API Spec file loaded from the kong db and presents with response extracted from examples provided in the specification. Swagger v2 and OpenAPI v3 specifications are supported.

Getting started guide: 
https://docs.google.com/document/d/1rtDrbxEe01PiKTqA2JTWsT94cllSKQpFohxg2yTbeVA/edit?usp=sharing

Video: 
https://drive.google.com/file/d/1NzOEjumaUBeMRXE2_LmJaCpasetEXz2N/view?usp=sharing

## Configuration

### Enabling the plugin on a Service

Configure this plugin on a [Service](https://docs.konghq.com/latest/admin-api/#service-object) by making the following request:

```
$ curl -X POST http://kong:8001/services/{service}/plugins \
  --data name=mocking \
  --data config.api_specification_filename=multipleexamples.json \
  --data config.random_delay=true \
  --data config.max_delay_time=1 \
  --data config.min_delay_time=0.01
```

`{service}` is the `id` or `name` of the Service that this plugin configuration will target.


### Enabling the plugin on a Route


Configure this plugin on a [Route](https://docs.konghq.com/latest/admin-api/#Route-object) with:

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
   --data name=mocking \
   --data config.api_specification_filename=multipleexamples.json \
   --data config.random_delay=true \
   --data config.max_delay_time=1 \
   --data config.min_delay_time=0.01
```

`{route}` is the `id` or `name` of the Route that this plugin configuration will target.


## Use cases:

### JSON and YAML support
Plugin is designed to consume both JSON and YAML spec files formats. Feel free to use either of the popular formats!

### Path Variables
Mocking api endpoints that are designed to accept Path Variables is seamless with Kong Mocking Plugin.

##### Quick Demo:
 
Consider your endpoint <b>/users/{id}</b> is configured as below in api spec file.

```
 paths:
 /users/{id}:
    get:
      summary: Returns an individual user
      description: Returns an individual user
      produces:
        - application/json
      parameters:
        - in: path
          name: id   # Note the name is the same as in the path
          required: true
          schema:
            type: integer
            minimum: 1
          description: The user ID
      responses:
        "200":
          description: OK
          examples:
            "application/json" : {
                                "sub": "jdoe",
                                "name": "Jane Doe",
                                }
```
###### Response from Mocking plugin:
```
vagrant@ubuntu-bionic:/$ http :8000/users/123 host:"example.com"
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 102
Content-Type: application/json; charset=utf-8
Date: Wed, 26 Aug 2020 18:04:48 GMT
Server: kong/1.5.0.4-enterprise-edition
X-Kong-Mocking-Plugin: true
X-Kong-Response-Latency: 3

{
    "name": "Jane Doe",
    "sub": "jdoe"
}
```
### Single Example 
Kong Mocking Plugin supports responses mocked using <b>example</b> attribute

#### Quick demo:

Consider your end point <b>/pet/findByStatus/singleExample</b> is provided with below example in your API Spec file 

                       "content": {
                            "application/json": {
                                "schema": {
                                    "type": "array",
                                    "items": {
                                        "$ref": "#/components/schemas/Pet"
                                    }
                                },
                                "example": {
                                    "summary": "Example response showing a regular response",
                                    "description": "Two pets are returned in this example.",
                                    "value": {
                                        "id": 1,
                                        "category": {
                                            "id": 1,
                                            "name": "cat"
                                        },
                                        "nickname": "fluffy",
                                        "photoUrls": [
                                            "http://example.com/path/to/cat/1.jpg",
                                            "http://example.com/path/to/cat/2.jpg"
                                        ],
                                        "tags": [{
                                            "id": 1,
                                            "name": "cat"
                                        }],
                                        "status": "available"
                                    }
                                }
                            }
                        }

###### Response from Mocking plugin:
```
vagrant@ubuntu-bionic:/$ http :8000/pet/findByStatus/singleExample  host:"example.com"
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 217
Content-Type: application/json; charset=utf-8
Date: Wed, 26 Aug 2020 19:03:00 GMT
Server: kong/1.5.0.4-enterprise-edition
X-Kong-Mocking-Plugin: true
X-Kong-Response-Latency: 6

{
    "category": {
        "id": 1,
        "name": "cat"
    },
    "id": 1,
    "nickname": "fluffy",
    "photoUrls": [
        "http://example.com/path/to/cat/1.jpg",
        "http://example.com/path/to/cat/2.jpg"
    ],
    "status": "available",
    "tags": [
        {
            "id": 1,
            "name": "cat"
        }
    ]
}

```

### Multiple Examples

Kong Mocking plugin supports multiple examples. Plugin extracts values of the examples and returns response for configured end point url.

Considering below examples are configured in api spec for end point <b>pet/findByStatus/MultipleExamples</b>
                                
                                "examples": {
                                    "No Content": {
                                        "summary": "Example response showing no pets are matched",
                                        "description": "An example response, using `value` property",
                                        "value": []
                                    },
                                    "Example 1": {
                                        "summary": "Example response showing a regular response",
                                        "description": "Two pets are returned in this example.",
                                        "value": [{
                                            "id": 1,
                                            "category": {
                                                "id": 1,
                                                "name": "cat"
                                            },
                                            "nickname": "fluffy",
                                            "photoUrls": [
                                                "http://example.com/path/to/cat/1.jpg",
                                                "http://example.com/path/to/cat/2.jpg"
                                            ],
                                            "tags": [{
                                                "id": 1,
                                                "name": "cat"
                                            }],
                                            "status": "available"
                                        }, {
                                            "id": 2,
                                            "category": {
                                                "id": 2,
                                                "name": "dog"
                                            },
                                            "nickname": "puppy",
                                            "photoUrls": [
                                                "http://example.com/path/to/dog/1.jpg"
                                            ],
                                            "tags": [{
                                                "id": 2,
                                                "name": "dog"
                                            }],
                                            "status": "available"
                                        }]
                                    }

###### Response from Mocking plugin:

```
vagrant@ubuntu-bionic:/$ http :8000/pet/findByStatus/MultipleExamples  host:"example.com"
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 394
Content-Type: application/json; charset=utf-8
Date: Wed, 26 Aug 2020 18:31:06 GMT
Server: kong/1.5.0.4-enterprise-edition
X-Kong-Mocking-Plugin: true
X-Kong-Response-Latency: 5

[
    {},
    {
        "category": {
            "id": 1,
            "name": "cat"
        },
        "id": 1,
        "nickname": "fluffy",
        "photoUrls": [
            "http://example.com/path/to/cat/1.jpg",
            "http://example.com/path/to/cat/2.jpg"
        ],
        "status": "available",
        "tags": [
            {
                "id": 1,
                "name": "cat"
            }
        ]
    },
    {
        "category": {
            "id": 2,
            "name": "dog"
        },
        "id": 2,
        "nickname": "puppy",
        "photoUrls": [
            "http://example.com/path/to/dog/1.jpg"
        ],
        "status": "available",
        "tags": [
            {
                "id": 2,
                "name": "dog"
            }
        ]
    }
]

```  

#### Filtering Multiple Examples with Query Parameters
Does your API accept Query Parameters? Wish you could filter the multiple examples you have configured in your api spec?

Kong Mocking Plugin got that covered! You could filter multiple examples by passing Queryparams to your end point url.

```
vagrant@ubuntu-bionic:/$ http :8000/pet/findByStatus/MultipleExamples?nickname=fluffy  host:"example.com"
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 219
Content-Type: application/json; charset=utf-8
Date: Wed, 26 Aug 2020 18:41:30 GMT
Server: kong/1.5.0.4-enterprise-edition
X-Kong-Mocking-Plugin: true
X-Kong-Response-Latency: 2

[
    {
        "category": {
            "id": 1,
            "name": "cat"
        },
        "id": 1,
        "nickname": "fluffy",
        "photoUrls": [
            "http://example.com/path/to/cat/1.jpg",
            "http://example.com/path/to/cat/2.jpg"
        ],
        "status": "available",
        "tags": [
            {
                "id": 1,
                "name": "cat"
            }
        ]
    }
]

```
#### Multiple Examples and Multiple Query Params
Pass on Multiple Query Parameters to your end point url to simulate real world use cases of your services

```
vagrant@ubuntu-bionic:/$ http :'8000/pet/findByStatus/MultipleExamples?nickname=fluffy&name=dog'  host:"example.com"
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 391
Content-Type: application/json; charset=utf-8
Date: Wed, 26 Aug 2020 18:47:55 GMT
Server: kong/1.5.0.4-enterprise-edition
X-Kong-Mocking-Plugin: true
X-Kong-Response-Latency: 1

[
    {
        "category": {
            "id": 1,
            "name": "cat"
        },
        "id": 1,
        "nickname": "fluffy",
        "photoUrls": [
            "http://example.com/path/to/cat/1.jpg",
            "http://example.com/path/to/cat/2.jpg"
        ],
        "status": "available",
        "tags": [
            {
                "id": 1,
                "name": "cat"
            }
        ]
    },
    {
        "category": {
            "id": 2,
            "name": "dog"
        },
        "id": 2,
        "nickname": "puppy",
        "photoUrls": [
            "http://example.com/path/to/dog/1.jpg"
        ],
        "status": "available",
        "tags": [
            {
                "id": 2,
                "name": "dog"
            }
        ]
    }
]

```

### Global plugins

- all plugins can be configured using the `http://kong:8001/plugins/` endpoint.

A plugin which is not associated to any Service, Route or Consumer (or API, if you are using an older version of Kong) is considered "global", and will be run on every request. Read the [Plugin Reference](https://docs.konghq.com/latest/admin-api/#add-plugin) and the [Plugin Precedence](https://docs.konghq.com/latest/admin-api/#precedence) sections for more information.


Here's a list of all the parameters which can be used in this plugin's configuration:

| Form Parameter | default | description
|----------------|---------|-------------
| `name`|| The name of the plugin to use, in this case: `mocking`.
| `service_id`|| The id of the Service which this plugin will target.
| `route_id` || The id of the Route which this plugin will target.
| `consumer_id` || The id of the Consumer which this plugin will target.
| `api_specification_filename`  || The name of the spec file loaded onto kong DB.
| `random_delay` <br>*optional* ||The boolean flag to enable random delay in the response. Used to introduce delays to simulate real time response times by apis
| `max_delay_time` <br>*optional* || The maximum value of delay time.
| `min_delay_time` <br>*optional* || The minimun value of delay time.
