module PrismicHelper

  def url_to_doc(doc, ref)
    document_path(id: doc.id, slug: doc.slug, ref: ref)
  end
  def link_to_doc(doc, ref, html_options={}, &blk)
    link_to(url_to_doc(doc, ref), html_options, &blk)
  end

  def display_doc(doc, ref)
    doc.as_html(link_resolver(ref)).html_safe
  end

  def link_resolver(ref)
    Prismic::LinkResolver.new(ref) do |doc|
      case doc.link_type
      when "article"
        root_path if doc.id == api.bookmark("home")
      when "argument"
        root_path + '#' + doc.id
      when "photogallery"
        gallery_path
      when "menupage"
        menu_path + '#' + doc.id
      end
    end
  end

  def privileged_access?
    connected? || PrismicService.access_token
  end

  def connected?
    !!@access_token
  end

  def current_ref
    @ref
  end

  def master_ref
    @api.master_ref.ref
  end

  def api
    @api
  end

end
