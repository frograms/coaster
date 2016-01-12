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

## StandardError raven extenstion

...
