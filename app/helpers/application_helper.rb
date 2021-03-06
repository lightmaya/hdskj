module ApplicationHelper

  # 格式化日期
  def show_date(d)
    (d.is_a?(Date) || d.is_a?(Time)) ? d.strftime("%Y-%m-%d") : d
  end


  # 消息类型
  def flash_status_chn(status)
    case status.to_sym
    when :error
      "操作失败！"
    when :success
      "操作成功！"
    else
      "温馨提示："
    end
  end

    # 显示序号
  def show_index(index, per = 20)
    params[:page] ||= 1
    (params[:page].to_i - 1) * per.to_i + index + 1
  end

  def link_to_blank(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second || {}
      link_to_blank(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2] || {}

      # override
      html_options.reverse_merge! target: '_blank'

      link_to(name, options, html_options)
    end
  end

def link_to_blank(*args, &block)
  if block_given?
    options      = args.first || {}
    html_options = args.second || {}
    link_to_blank(capture(&block), options, html_options)
  else
    name         = args[0]
    options      = args[1] || {}
    html_options = args[2] || {}

    # override
    html_options.reverse_merge! target: '_blank'

    link_to(name, options, html_options)
  end
end

  # ancient edit and destroy links
def operate_buttons(object, options = {}, &block)
  return "" if object.blank?
  lis = ""
  options = options.with_indifferent_access
  if object.is_a?(Array)
    lis = object.map{|link| "<li>#{link}</li>" }.join("")
  elsif object.present?
    options[:namespace] = "ancient" if options[:namespace].nil?
    namespace = options[:namespace]
    links = []
    edit_path = eval("#{['edit', namespace, object.class.to_s.tableize.singularize, 'path'].compact.join('_')}(#{object.id},:back => request.fullpath)")
    destroy_path = eval("#{[namespace, object.class.to_s.tableize.singularize, 'path'].compact.join('_')}(#{object.id},:back => request.fullpath)")

    links << link_to('修改', edit_path)
    links << link_to('删除', destroy_path, :method => 'delete', :confirm =>'您确定吗？')
    links += options[:links] if options[:links].present?
    lis = links.map{|link| "<li>#{link}</li>" }.join("")
    if block_given?
      lis << capture(&block)
    end
  end
  html = %Q|
    <div class="btn-group">
      <button class="btn btn-primary btn-small dropdown-toggle" data-toggle="dropdown">#{options[:label_name]||'操作'}<span class="caret"></span></button>
      <ul class="dropdown-menu">
        #{lis}
      </ul>
    </div>
  |.html_safe
end

 #  截取字符串固定长度，支持中英文混合，length 为中文的长度，一个英文相当于0.5个中文长度
  def text_truncate(text, length = 30, truncate_string = "...")
    if text
      l=0
      char_array=text.unpack("U*")
      char_array.each_with_index do |c,i|
        l = l+ (c<127 ? 0.5 : 1)
        if l>=length
          return char_array[0..i].pack("U*")+(i ? truncate_string : "")
        end
      end
      return text
    else
      return ""
    end
  end

  #  无限级联下拉框 搭配js
  def dynamic_selects(data_or_class, value_id, aim_id=nil, options = {})
    data_class = data_or_class.is_a?(Class) ? data_or_class : data_or_class.first.class
    options[:include_blank] ||= "请选择"
    options.merge!({:class => 'multi-level form-control', :otype => data_class.to_s, :aim_id => aim_id })
    roots = data_or_class.is_a?(Class) ? data_class.roots : data_or_class
    if options[:reject_ids]
      roots = roots.delete_if{|root| options[:reject_ids].include?(root.id)}
      options.merge!({:reject_ids => options[:reject_ids].join(",") })
    end
    value_object = data_or_class.find_by_id(value_id)
    select_text = value_object.try(:has_children?) ? collection_select('value_object-parent-id', 0, value_object.children, :id, :name, {:selected => value_object.try(:id), :include_blank => options[:include_blank]}, options) : ''
    #aim_id = object.class.to_s.tableize.singularize + "_" + ref.to_s.singularize + "_id"
    aim_id = aim_id.to_s
    while value_object and value_object.parent
      select_text = collection_select('value_object-parent-id', value_object.id, value_object.parent.children, :id, :name, {:selected => value_object.try(:id), :include_blank => options[:include_blank]}, options) << select_text
      value_object = value_object.parent
    end
    select_text = collection_select('value_object-parent-id', 0, roots, :id, :name, {:selected => value_object.try(:id), :include_blank => options[:include_blank]}, options) << select_text

    raw select_text
  end


  # 下拉选择框
  def art_select(to_id, rs,  url, options = {})
    options.merge!({:class => 'drop_select', :readonly => "readonly", :dropdata => url})
    options[:droplimit] ||= "0"
    options[:droptree] ||= "true"
    input_id = to_id.gsub('[', "_").gsub(']', '_')
    if rs.blank?
      name_value = id_value = ""
    elsif rs.class == Array
      name_value = rs.map(&:name).join(",")
      id_value = rs.map(&:id).join(",")
    elsif options[:from] == 'ArticleCategroy'
      name_value = rs.split(',').map{|artid| ArticleCategroy.find(artid).name}.join(',').to_s
      id_value = rs
    else
      name_value = rs.name
      id_value = rs.id
    end
    name_value = options[:str] if options[:str]
    (text_field_tag("art_#{to_id}", name_value, options.merge({:id => "art_#{input_id}"})) + hidden_field_tag(to_id, id_value, :droptree_id => "art_#{input_id}" )).html_safe
  end


end
