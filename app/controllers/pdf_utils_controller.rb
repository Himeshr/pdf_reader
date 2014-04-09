class PdfUtilsController < ApplicationController

  # GET pdf_utils/new
  def new
  end

  # POST pdf_utils/process_pdf
  def process_pdf
    puts params.inspect
    @data = PdfUtil.process(params[:pdf])
    render 'index'
  end
end
