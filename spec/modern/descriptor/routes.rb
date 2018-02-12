# frozen_string_literal: true

unless Object.constants.include? :RequestBodyTest
  module RequestBodyTest
    class RetBody < Modern::Struct
      attribute :a, Modern::Types::Strict::Int
      attribute :b, Modern::Types::Coercible::Int
      attribute :c, Modern::Types::Strict::Int.optional.default(nil)
      attribute :d, (Modern::Types::Strict::Int | Modern::Types::Strict::String).optional.default(nil)
    end

    class Subclass < Modern::Struct
      attribute :foo, Modern::Types::Strict::Int
    end

    class ExclusiveSubA < Modern::Struct; end
    class ExclusiveSubB < Modern::Struct; end

    class Parent < Modern::Struct
      attribute :req, Modern::Types::Strict::String
      attribute :opt, Modern::Types::Strict::String.optional
      attribute :optdef, Modern::Types::Strict::String.optional.default(nil)
      attribute :sub, Modern::Types.Instance(Subclass)
      attribute :exsub, Modern::Types.Instance(ExclusiveSubA) |
                        Modern::Types.Instance(ExclusiveSubB)
      attribute :hash, Modern::Types::Strict::Hash.strict(
        first: Modern::Types::Strict::String,
        last: Modern::Types::Strict::Int.optional
      )
      attribute :array, Modern::Types::Strict::Array.of(
        Modern::Types.Instance(Subclass)
      )
    end
  end
end

unless Object.constants.include? :ContentTest
  module ContentTest
    class RespBody < Modern::Struct
      attribute :a, Modern::Types::Strict::String
      attribute :b, Modern::Types::Coercible::Int
    end
  end
end

shared_context "request body routes" do
  let(:required_body_hash_route) do
    Modern::Descriptor::Route.new(
      id: "postRequiredBodyHash",
      http_method: :POST,
      path: "/required-body-hash",
      summary: "when the request body is required for a hash",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      request_body:
        Modern::Descriptor::RequestBody.new(
          type: Modern::Types::Strict::Hash.strict_with_defaults(
            a: Modern::Types::Strict::Int,
            b: Modern::Types::Coercible::Int,
            c: Modern::Types::Strict::Int.optional.default(nil)
          ),
          required: true
        ),
      action:
        proc do
          body
        end
    )
  end

  let(:required_body_struct_route) do
    Modern::Descriptor::Route.new(
      id: "postRequiredBodyStruct",
      http_method: :POST,
      path: "/required-body-struct",
      summary: "when the request body is required for a struct",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      request_body:
        Modern::Descriptor::RequestBody.new(
          type: RequestBodyTest::RetBody,
          required: true
        ),
      action:
        proc do
          body
        end
    )
  end

  let(:required_nested_struct_route) do
    Modern::Descriptor::Route.new(
      id: "postRequiredBodyNestedStruct",
      http_method: :POST,
      path: "/required-body-nested-struct",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      request_body:
        Modern::Descriptor::RequestBody.new(
          type: RequestBodyTest::Parent,
          required: true
        ),
      action:
        proc do
          body
        end
    )
  end
end

shared_context "security routes" do
  let(:http_bearer) do
    Modern::Descriptor::Route.new(
      id: "getHttpBearer",
      http_method: :GET,
      path: "/http-security/bearer",
      summary: "a route that tests for Bearer scheme in the Authorization header",
      security: [
        Modern::Descriptor::Security::Http.new(
          name: "httpBearerFoo",
          description: "a bearer token with the value of 'foo' is required.",
          scheme: "Bearer",
          validation: proc { |v| v == "foo" }
        )
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          { success: true }
        end
    )
  end

  let(:http_multi) do
    Modern::Descriptor::Route.new(
      id: "getHttpMulti",
      http_method: :GET,
      path: "/http-security/multi",
      summary: "a route that tests for a Bearer or NotBearer scheme in the Authorization header",
      security: [
        Modern::Descriptor::Security::Http.new(
          name: "httpMultiBearerFoo",
          scheme: "Bearer",
          validation: proc { |v| v == "foo" }
        ),
        Modern::Descriptor::Security::Http.new(
          name: "httpMultiNotBearerBar",
          scheme: "NotBearer",
          validation: proc { |v| v == "bar" }
        ),
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          { success: true }
        end
    )
  end

  let(:apikey_query) do
    Modern::Descriptor::Route.new(
      id: "getApiKeyQuery",
      http_method: :GET,
      path: "/apikey-security/query",
      summary: "a route that tests for a Token query parameter",
      security: [
        Modern::Descriptor::Security::ApiKey.new(
          name: "queryTokenFoo",
          parameter: Modern::Descriptor::Parameters::Query.new(
            name: "token",
            type: Modern::Types::Strict::String
          ),
          validation: proc { |v| v == "foo" }
        ),
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          { success: true }
        end
    )
  end

  let(:apikey_header) do
    Modern::Descriptor::Route.new(
      id: "getApiKeyHeader",
      http_method: :GET,
      path: "/apikey-security/header",
      summary: "a route that tests for a X-Modern-Token header",
      security: [
        Modern::Descriptor::Security::ApiKey.new(
          name: "headerFoo",
          parameter: Modern::Descriptor::Parameters::Header.new(
            name: "token",
            header_name: "X-Modern-Token",
            type: Modern::Types::Strict::String
          ),
          validation: proc { |v| v == "foo" }
        ),
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          { success: true }
        end
    )
  end

  let(:apikey_cookie) do
    Modern::Descriptor::Route.new(
      id: "getApiKeyCookie",
      http_method: :GET,
      path: "/apikey-security/cookie",
      summary: "a route that tests for a Modern-Token cookie",
      security: [
        Modern::Descriptor::Security::ApiKey.new(
          name: "cookieFoo",
          parameter: Modern::Descriptor::Parameters::Cookie.new(
            name: "token",
            cookie_name: "Modern-Token",
            type: Modern::Types::Strict::String
          ),
          validation: proc { |v| v == "foo" }
        ),
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          { success: true }
        end
    )
  end
end

shared_context "parameter routes" do
  let(:query_route) do
    Modern::Descriptor::Route.new(
      id: "getQuery",
      http_method: :GET,
      path: "/query-form",
      summary: "A query parameter",
      parameters: [
        Modern::Descriptor::Parameters::Query.new(
          name: "a",
          type: Modern::Types::Coercible::Int,
          required: true
        ),
        Modern::Descriptor::Parameters::Query.new(
          name: "b",
          type: Modern::Types::Coercible::String,
          required: true
        ),
        Modern::Descriptor::Parameters::Query.new(
          name: "c",
          type: Modern::Types::Coercible::Int,
          required: false
        )
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          response.bypass!
          response.json(params)
        end
    )
  end

  let(:header_route) do
    Modern::Descriptor::Route.new(
      id: "getHeader",
      http_method: :GET,
      path: "/header-simple",
      summary: "A header parameter",
      parameters: [
        Modern::Descriptor::Parameters::Header.new(
          name: "a",
          header_name: "My-Header-A",
          type: Modern::Types::Coercible::Int,
          required: true
        ),
        Modern::Descriptor::Parameters::Header.new(
          name: "b",
          header_name: "My-Header-B",
          type: Modern::Types::Coercible::String,
          required: true
        ),
        Modern::Descriptor::Parameters::Header.new(
          name: "c",
          header_name: "My-Header-C",
          type: Modern::Types::Coercible::Int,
          required: false
        )
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          response.bypass!
          response.json(params)
        end
    )
  end

  let(:cookie_route) do
    Modern::Descriptor::Route.new(
      id: "getCookie",
      http_method: :GET,
      path: "/cookie-form",
      summary: "A cookie parameter",
      parameters: [
        Modern::Descriptor::Parameters::Cookie.new(
          name: "a",
          cookie_name: "My-Cookie-A",
          type: Modern::Types::Coercible::Int,
          required: true
        ),
        Modern::Descriptor::Parameters::Cookie.new(
          name: "b",
          cookie_name: "My-Cookie-B",
          type: Modern::Types::Coercible::String,
          required: true
        ),
        Modern::Descriptor::Parameters::Cookie.new(
          name: "c",
          cookie_name: "My-Cookie-C",
          type: Modern::Types::Coercible::Int,
          required: false
        )
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          response.bypass!
          response.json(params)
        end
    )
  end

  let(:path_route) do
    Modern::Descriptor::Route.new(
      id: "getPath",
      http_method: :GET,
      path: "/path-simple/{a}/{b}/{c}",
      summary: "A path parameter test",
      parameters: [
        Modern::Descriptor::Parameters::Path.new(
          name: "a",
          type: Modern::Types::Coercible::Int
        ),
        Modern::Descriptor::Parameters::Path.new(
          name: "b",
          type: Modern::Types::Coercible::String
        ),
        Modern::Descriptor::Parameters::Path.new(
          name: "c",
          type: Modern::Types::Coercible::Int
        )
      ],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      action:
        proc do
          response.bypass!
          response.json(params)
        end
    )
  end
end

shared_context "content routes" do
  let(:good_route_scalar) do
    Modern::Descriptor::Route.new(
      id: "getGoodRouteScalar",
      http_method: :GET,
      path: "/good-route-scalar",
      summary: "a working route that returns a scalar value",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              type: Modern::Types::Strict::Int
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          5
        end
    )
  end

  let(:bad_route_scalar) do
    Modern::Descriptor::Route.new(
      id: "getBadRouteScalar",
      http_method: :GET,
      path: "/bad-route-scalar",
      summary: "a route that fails to return a scalar value",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              type: Modern::Types::Strict::Int
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          "5"
        end
    )
  end

  let(:good_route_hash) do
    Modern::Descriptor::Route.new(
      id: "getGoodRouteHash",
      http_method: :GET,
      path: "/good-route-hash",
      summary: "a working route that returns a hash",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              type: Modern::Types::Strict::Hash.strict(
                a: Modern::Types::Strict::String,
                b: Modern::Types::Coercible::Int
              )
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          { a: "foo", b: "10" }
        end
    )
  end

  let(:bad_route_hash) do
    Modern::Descriptor::Route.new(
      id: "getBadRouteHash",
      http_method: :GET,
      path: "/bad-route-hash",
      summary: "an invalid route that fails to return a hash",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              type: Modern::Types::Strict::Hash.strict(
                a: Modern::Types::Strict::String,
                b: Modern::Types::Coercible::Int
              )
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          { a: "foo", b: nil }
        end
    )
  end

  let(:good_route_struct) do
    Modern::Descriptor::Route.new(
      id: "getGoodRouteStruct",
      http_method: :GET,
      path: "/good-route-struct",
      summary: "a working route that returns a hash through a Modern::Struct",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              type: ContentTest::RespBody
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          { a: "foo", b: "10" }
        end
    )
  end

  let(:bad_route_struct) do
    Modern::Descriptor::Route.new(
      id: "getBadRouteStruct",
      http_method: :GET,
      path: "/bad-route-struct",
      summary: "an invalid route that fails to return through a Modern::Struct",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              type: ContentTest::RespBody
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          { a: "foo", b: nil }
        end
    )
  end
end
