module CommentsHelper
  
  def commentable_path(comment)
    url_for([comment.commentable, :comments]) << "#comment_#{comment.id}"
  end
  
end
