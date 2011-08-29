module FormatResponse

  #Clearly we should not be setting the content_type in a module called 'FormatResponse'
  def format_response result_hsh,precooked_mtype=nil

    # Please uncomment whenever my shoddy code begins to weigh too heavily on
    # your conscience - David
    # terrible_hack_penance = 3
    # terrible_hack_penance.times{ say_hail_mary() }

    if precooked_mtype
      media = media_type_string(precooked_mtype)
      body  = result_hsh
    else
      media = request.accept_media_types.prefered
      mtype = media_type_sym(media)
      body  = convert_result(result_hsh, mtype)
    end
    content_type media
    body + "\n"
  end

  def convert_result result_hsh, mtype
    case
    when  mtype == :xml                                then                      result_hsh.to_xml.chomp
    when (mtype == :json) && (params[:_pretty].blank?) then JSON.generate        result_hsh
    when  mtype == :json                               then JSON.pretty_generate result_hsh
    when  mtype == :yaml                               then YAML.dump            result_hsh.to_hash
    else                                                    JSON.pretty_generate result_hsh
    end
  end

  # json_p is text/javascript: it's a program not data
  # json    is application/json: http://tools.ietf.org/html/rfc4627
  #
  def media_type_sym media
    case
    when (media =~ %r{^application/xml})                    then :xml
    when (media =~ %r{^application/json})                   then :json
    when (media =~ %r{^application/json-p})                 then :json
    when (media =~ %r{^(application|text)/(x-)?javascript}) then :json
    when (media =~ %r{^(application|text)/(x-)?ecmascript}) then :json
    when (media =~ %r{^text/yaml})                          then :yaml
    # when (media =~ %r{^text/tab-separated-values})         then :tsv
    # when (media =~ %r{^text/(comma-separated-values|csv)}) then :csv
    # when (media =~ %r{^text/html})                         then :html
    else :json
    end
  end

  def media_type_string media_sym
    case
    when (media_sym == :xml)                                    then "application/xml"
    when (media_sym == :json)                                   then "application/json"
    when (media_sym == :yaml)                                   then "text/yaml"
    else "application/json"
    end
  end

end

# text/comma-separated-values, text/csv, application/csv, application/excel, application/vnd.ms-excel, application/vnd.msexcel, text/anytext
# text/xml, application/xml, application/x-xml
# application/x-javascript, text/javascript
# application/json
# text/tab-separated-values
