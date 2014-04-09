class PdfUtil
  DATE_REGEX = '(([012][0-9])|([3][01]))\/(([0][1-9])|([1][012]))\/([\d]{4})'

  class << self
    # This method accept the pdf file object and extract the require data.
    # parameters : file object of pdf file.
    # Return Types : hash with reuire data.
    def process(file)
      file = file.tempfile
      # Read pdf file.
      pdf_text = RPDFBox::TextExtraction.get_text_all(file.path)
      data = {}
      company_and_client_name(data, pdf_text)
      contact_no(data, pdf_text)
      bill_charges(data, pdf_text)
      data
    end

    # This method extract the contact number from given string.
    # Contact number formate should be (123 123 1234, 123-123-1234)
    # Parametrs: hash object and string.
    # Return Type : contact number is added in hash.
    def contact_no(data, pdf_text)
      txt = pdf_text.match(/(?=VAT\sREG)[^>]+((?<=(([012][0-9])|([3][01]))\/(([0][1-9])|([1][012]))\/([\d]{4})))/m)[0]
      data[:contact_no] = txt.match(/([\d]{3}(\s|-)[\d]{3}(\s|-)[\d]{4})/m)[0]
    end

    # This method extract the company name and client name from given string.
    # Parametrs: hash object and string.
    # Return Type : client name and company name is hash.
    def company_and_client_name(data, pdf_text)
      company_client_name = pdf_text.match(/(?<=(([012][0-9])|([3][01]))\/(([0][1-9])|([1][012]))\/([\d]{4}))(.)*(?=P O BOX)/m)[0]
      data[:client_name] = company_client_name.split("\n")[-1]
      data[:company_name] = company_client_name.split("\n")[-2]
    end

    # This method ectract the table bill data from given string.
    # Parameter: hash and string.
    # Return Type : added bill data in hash.
    def bill_charges(data, pdf_text)
      bill_data = pdf_text.match(/(?<=DATE TRANSACTION AMOUNT)(.)*(?=TOTAL EXCLUDING VAT)/m)[0]
      bill_data = bill_data.split("\n").reject{|i| i.blank? }
      process_bill_data(data, bill_data)
      #
    end

    # This method extract the row data from string.
    # Parameter : hash and string
    # Return Type : added bill data in hash.
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