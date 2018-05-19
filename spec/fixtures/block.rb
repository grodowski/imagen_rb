# frozen_string_literal: true

(1..3).each(&lambda { |x|
  puts x
})

get :users do |env, _params|
  if env[:name] == 'Bob'
    return [
      '200',
      {'Content-Type' => 'application/json'},
      [{name: 'Bob'}.to_json]
    ]
  end
  ['404', {}, []]
end
