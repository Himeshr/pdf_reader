class PdfUtilsController < ApplicationController

  def new
  end

  def process_pdf
    puts params.inspect
    @data = PdfUtil.process(params[:pdf])
    render 'index'
  end
end
