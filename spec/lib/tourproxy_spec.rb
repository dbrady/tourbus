require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TourProxy do
  it "should replace known hostnames"
    # given a list of known hostnames,
    # when I process a request matching a hosts,
    # then the request uri should be rewritten with the variable's expansion
  
  it "should emit AMF blobs"
  it "should emit get/post blobs for unrecognized types"
  
  # when doing an html get
      # with no params
          # it should log "visit 'url'"
          # and should not log "visit 'url', :get" etc
  
  
end

