Pod::Spec.new do |s|
s.name = 'PDPullToRefresh'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = 'An easy way to use pull-to-refresh.'
s.homepage = 'https://github.com/v2panda/PDPullToRefresh'
s.authors = { 'v2panda' => 'pdxuzhen@gmail.com' }
s.source = { :git => 'https://github.com/v2panda/PDPullToRefresh.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '8.0'
s.source_files = 'PDPullToRefresh/PDPullToRefresh/*.{h,m}'
end
