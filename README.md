# Coaster

## Object Translation

Translate by object class name.
```ruby
                                  # Translation key
Coupon._translate                 #=> en.class.Coupon.self
Coupon::Discount._translate       #=> en.class.Coupon.Discount.self
Coupon._translate('.title')       #=> en.class.Coupon.title
Coupon._translate('root')         #=> en.root
```

Pass translation params.
```ruby
class Coupon
  class << self
    def _translation_params
      {name: 'Buzz'}
    end
  end
end

Coupon._translate #=> I18n.t('en.class.Coupon.self', {name: 'Buzz'})
```

Inheritance fallback.
```ruby
class Order
end

class CreditCard < Order
end

# in en.yml only defined Order translation.
# use superclass _translate
CreditCard._translate #=> I18n.t('en.class.CreditCard.self') not exists
                      #=> I18n.t('en.class.Order.self') returned
```

instance 에서도 사용할 수 있다.
```ruby
Foo::Bar.new._translate            #=> return translation 'class.Foo.Bar.self'
Foo::Bar.new._translate('.title')  #=> return translation 'class.Foo.Bar.title'
Foo::Bar.new._translate('title')   #=> return translation 'title'
Foo::Bar.new._translate(:force)    #=> ignore 'message' even if message exists
```

그런데 다른점은 instance에 message 메서드가 존재할 경우 다음과 같이 message를 활용한다.
```ruby
error = Order::Error.new('error message')
error._translate(:force) #=> "error message"
```


## StandardError features

아래는 동일하다.
```ruby
raise Order::Error, 'order error occurred'
raise Order::Error, {message: 'order error occurred'}
raise Order::Error, {msg: 'order error occurred'}
raise Order::Error, {m: 'order error occurred'}
```

에러에 추가로 attribute를 추가하고 싶다면 Hash에 아무거나 넣으면 된다.
```ruby
ex = catch { raise Order::Error, {m: 'message', order: order} }
ex.attributes[:order] #=> order instance
```

Hash로 전달되는 특수한 attribute가 있다.

1. desc, description: `ex.description`으로 꺼낼 수 있다. `ex.message`는 사용자 친화적이지
   않은 메시지라서 사용자 친화적인 메시지를 넣으려면 description을 쓰면 된다. description이 없으면
   message를 리턴한다.
1. obj, object: `ex.object`로 꺼낼수 있다.
1. http_status: `ex.http_status`로 꺼낼수 있다. 기본값은 Error Class에서 지정된 상수값.


그 외에 error instance variable로 등록되는 attribute가 있다.
1. tags: [ActiveSupport::TaggedLogging|http://api.rubyonrails.org/classes/ActiveSupport/TaggedLogging.html]에 사용된다.
1. level: debug, info 등등의 로깅 레벨
1. tkey: Object Translation 에서 사용된다. 기본값은 '.self'와 동일하다.

## StandardError#logging

`StandardError#logging`으로 로깅한다.   
logger는 `Coaster.logger=`를 사용하며 설정이 안돼있을 경우 `Rails.logger`를 사용한다.   
cleaner(`AcitveSupport::BacktraceCleaner`)는 `StandardError.cleaner=`, `StandardError.cause_cleaner=`를 사용하며
기본값은 없으며 cleaner가 없을 경우 backtrace를 출력하지 않는다.

1. options
  1. `:logger` => 기본 logger를 대체할 logger
  1. `:cleaner` => 해당 에러를 로깅할때 사용할 cleaner
1. before_logging_blocks, after_loggin_blocks
  1. `logging` 전후 처리를 추가할 수 있으며 추가된 block은 error instance 내에서 실행된다.
  1. ```
     StandardError.before_logging(:cloudwatch) do
       ReportCloudWatch.send(self) # self가 에러 자신
     end
     ```
1. log 내용은 `StandardError#to_detail`을 사용

## StandardError#to_detail
`logging` 메서드에서 출력한 메시지를 만든다.

  1. error class, status, message, instance_variables(, backtrace) 순서대로 출력하며   
     cause가 존재할 경우 CAUSE이후 tab indent를 하여 출력한다. cause는 최대 3 depth까지 출력한다.
  1. instance_variable
    1. `StandardError.detail_vars` Array에서 있는 값의 출력은 `StandardError.detail_value_proc`으로 출력한다.
      1. `detail_vars` 기본값은 `%i[@attributes @tkey @fingerprint @tags @level]`
      1. `detail_value_proc` 기본값은 `Proc.new{|val| val.inspect}`
    1. 나머지는 `StandardError.detail_value_simpe`로 처리하며 class name만 사용한다.

## coaster/rails_ext/backtrace_cleaner

[`AcitveSupport::BacktraceCleaner`](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/backtrace_cleaner.rb)에서
앞쪽은 `silence!`에서 제외하는(즉 모든 backtrace가 포함되는) 로직이 추가된다.   
앞쪽에서 얼마나 포함할지는 `cleaner.minimum_first=`로 설정하며 기본값은 10이다.   
minimum_first 이후 silence된 backtrace사이에 `BacktraceCleaner.minimum_first ... and next silenced backtraces`라인이 끼워진다.

## StandardError logging example with backtrace cleaner

```
[Dynamoid::Errors::RecordNotUnique] status:999999
	MESSAGE: Attempted to write record #<DynamoUserIdentificationLog:0x00005592491a7378> when its key already exists
	@attributes: {}
	@fingerprint: [:default, :class]
	@inner_exception: Attempted to write record #<DynamoUserIdentificationLog:0x00005592491a7378> when its key already exists
	@level: "error"
	@original_exception: Dynamoid::Errors::ConditionalCheckFailedException
	@raven: {}
	@tags: {}
	@tkey: nil
	BACKTRACE:
		dynamoid (3.7.1) lib/dynamoid/persistence/save.rb:30:in `rescue in call'
		dynamoid (3.7.1) lib/dynamoid/persistence/save.rb:15:in `call'
		dynamoid (3.7.1) lib/dynamoid/persistence/save.rb:8:in `call'
		dynamoid (3.7.1) lib/dynamoid/persistence.rb:485:in `block (2 levels) in save'
		activesupport (6.1.4.4) lib/active_support/callbacks.rb:106:in `run_callbacks'
		dynamoid (3.7.1) lib/dynamoid/persistence.rb:484:in `block in save'
		activesupport (6.1.4.4) lib/active_support/callbacks.rb:106:in `run_callbacks'
		dynamoid (3.7.1) lib/dynamoid/persistence.rb:483:in `save'
		dynamoid (3.7.1) lib/dynamoid/dirty.rb:50:in `save'
		dynamoid (3.7.1) lib/dynamoid/validations.rb:19:in `save'
		BacktraceCleaner.minimum_first ... and next silenced backtraces
		exmaple_app/app/models/dynamo_user_identification_log.rb:39:in `record!'
		exmaple_app/app/models/sample_model.rb:156:in `record_authentication_log'
		vendor/bundle/ruby/2.7.0/bin/rspec:25:in `load'
		vendor/bundle/ruby/2.7.0/bin/rspec:25:in `<top (required)>'
		/home/circleci/.rubygems/bin/bundle:25:in `load'
		/home/circleci/.rubygems/bin/bundle:25:in `<main>'
	CAUSE: [Dynamoid::Errors::ConditionalCheckFailedException] status:999999
		MESSAGE: The conditional request failed
		@attributes: {}
		@fingerprint: [:default, :class]
		@inner_exception: Aws::DynamoDB::Errors::ConditionalCheckFailedException
		@level: "error"
		@raven: {}
		@tags: {}
		@tkey: nil
		BACKTRACE:
			dynamoid (3.7.1) lib/dynamoid/adapter_plugin/aws_sdk_v3.rb:471:in `rescue in put_item'
			dynamoid (3.7.1) lib/dynamoid/adapter_plugin/aws_sdk_v3.rb:462:in `put_item'
			dynamoid (3.7.1) lib/dynamoid/adapter.rb:153:in `block (3 levels) in <class:Adapter>'
			dynamoid (3.7.1) lib/dynamoid/adapter.rb:56:in `benchmark'
			dynamoid (3.7.1) lib/dynamoid/adapter.rb:153:in `block (2 levels) in <class:Adapter>'
			dynamoid (3.7.1) lib/dynamoid/adapter.rb:71:in `write'
			dynamoid (3.7.1) lib/dynamoid/persistence/save.rb:24:in `call'
			dynamoid (3.7.1) lib/dynamoid/persistence/save.rb:8:in `call'
			dynamoid (3.7.1) lib/dynamoid/persistence.rb:485:in `block (2 levels) in save'
			activesupport (6.1.4.4) lib/active_support/callbacks.rb:106:in `run_callbacks'
			BacktraceCleaner.minimum_first ... and next silenced backtraces
			exmaple_app/app/models/dynamo_user_identification_log.rb:39:in `record!'
			exmaple_app/app/models/sample_model.rb:156:in `record_authentication_log'
			vendor/bundle/ruby/2.7.0/bin/rspec:25:in `load'
			vendor/bundle/ruby/2.7.0/bin/rspec:25:in `<top (required)>'
			/home/circleci/.rubygems/bin/bundle:25:in `load'
			/home/circleci/.rubygems/bin/bundle:25:in `<main>'
		CAUSE: [Aws::DynamoDB::Errors::ConditionalCheckFailedException] status:999999
			MESSAGE: The conditional request failed
			@attributes: {}
			@code: ConditionalCheckFailedException
			@context: Seahorse::Client::RequestContext
			@data: Aws::DynamoDB::Types::ConditionalCheckFailedException
			@fingerprint: [:default, :class]
			@level: "error"
			@message: The conditional request failed
			@raven: {}
			@tags: {}
			@tkey: nil
			BACKTRACE:
				aws-sdk-core (3.130.0) lib/seahorse/client/plugins/raise_response_errors.rb:17:in `call'
				aws-sdk-dynamodb (1.69.0) lib/aws-sdk-dynamodb/plugins/simple_attributes.rb:119:in `call'
				aws-sdk-core (3.130.0) lib/aws-sdk-core/plugins/jsonvalue_converter.rb:22:in `call'
				aws-sdk-core (3.130.0) lib/aws-sdk-core/plugins/idempotency_token.rb:19:in `call'
				aws-sdk-core (3.130.0) lib/aws-sdk-core/plugins/param_converter.rb:26:in `call'
				aws-sdk-core (3.130.0) lib/seahorse/client/plugins/request_callback.rb:71:in `call'
				aws-sdk-core (3.130.0) lib/aws-sdk-core/plugins/response_paging.rb:12:in `call'
				aws-sdk-core (3.130.0) lib/seahorse/client/plugins/response_target.rb:24:in `call'
				aws-sdk-core (3.130.0) lib/seahorse/client/request.rb:72:in `send_request'
				aws-sdk-dynamodb (1.69.0) lib/aws-sdk-dynamodb/client.rb:4147:in `put_item'
				BacktraceCleaner.minimum_first ... and next silenced backtraces
				example_app/app/models/dynamo_user_identification_log.rb:39:in `record!'
				example_app/app/models/sample_model.rb:156:in `record_authentication_log'
				vendor/bundle/ruby/2.7.0/bin/rspec:25:in `load'
				vendor/bundle/ruby/2.7.0/bin/rspec:25:in `<top (required)>'
				/home/circleci/.rubygems/bin/bundle:25:in `load'
				/home/circleci/.rubygems/bin/bundle:25:in `<main>'
```
