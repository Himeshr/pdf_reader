class PdfUtil
  DATE_REGEX = '(([012][0-9])|([3][01]))\/(([0][1-9])|([1][012]))\/([\d]{4})'

  class << self
    def process(file)
      file = file.tempfile
      pdf_text = RPDFBox::TextExtraction.get_text_all(file.path)
      data = {}
      company_and_client_name(data, pdf_text)
      contact_no(data, pdf_text)
      bill_charges(data, pdf_text)
      data
    end

    def contact_no(data, pdf_text)
      txt = pdf_text.match(/(?=VAT\sREG)[^>]+((?<=(([012][0-9])|([3][01]))\/(([0][1-9])|([1][012]))\/([\d]{4})))/m)[0]
      data[:contact_no] = txt.match(/([\d]{3}(\s|-)[\d]{3}(\s|-)[\d]{4})/m)[0]
    end

    def company_and_client_name(data, pdf_text)
      company_client_name = pdf_text.match(/(?<=(([012][0-9])|([3][01]))\/(([0][1-9])|([1][012]))\/([\d]{4}))(.)*(?=P O BOX)/m)[0]
      data[:client_name] = company_client_name.split("\n")[-1]
      data[:company_name] = company_client_name.split("\n")[-2]
    end

    def bill_charges(data, pdf_text)
      bill_data = pdf_text.match(/(?<=DATE TRANSACTION AMOUNT)(.)*(?=TOTAL EXCLUDING VAT)/m)[0]
      bill_data = bill_data.split("\n").reject{|i| i.blank? }
      process_bill_data(data, bill_data)
      #
    end

    def process_bill_data(data, bill_data)
      bill_charges = []
      bill_data.each do |b|
        table_row = b.match(/(([012][0-9]|[3][01])\/([0][1-9]|[1][012])\/([\d]{4}))?\s([A-Z\-\d\sa-z]*)\s([\-]?[\d]+[\.][\d]{2})$/)
        bill_charges << [table_row[1], table_row[5], table_row[6]]
      end
      data[:bill_charges] = bill_charges

    end
  end

end