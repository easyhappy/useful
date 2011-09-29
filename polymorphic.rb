（1）建立表search_keys
company_id, resource_type, resource_id, content_name, centent_value

(2) 定义路由 :company_number/search

(3)定义controller名字searches

(3) 在model层 product, contact建立与search_key的一对多关系.

(4)create, update, destroy 时候 往表search_key里面插入

(5)点击查找 到search的show里面去查找
   url :company_number/search/xxxxxx


  get 'search'      => ':company_number/search'
  get 'search_for'  => ':company_number/search/:key'

  #generate
  search_path
  url = search_path(current_company)
  form_for(url) do
  end


（1） 登录

（2) 删除所有的表search_keys 的所有信息

（2） 创建一个商品， 查看是否 在search_keys 里面 新建了 两条记录

（3）点击全局查找 传入 key 查看 查找结果

（4） update 一个商品 查看search_keys是否 还是两条记录

（3）点击全局查找 传入 key 查看 查找结果

（5）destroy 一个商品 查看 search_keys 是否减去两条记录

（3）点击全局查找 传入 key 查看 查找结果
