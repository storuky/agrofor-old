class Document < ActiveRecord::Base
  mount_uploader :document, DocumentUploader

  def file
    self.document.file.filename
  end
end
