Erp::Payments::PaymentType.destroy_all
Erp::Payments::PaymentType.create(name: 'Đơn hàng bán lẻ', code: Erp::Payments::PaymentType::CODE_SALES_ORDER, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true, is_receivable: true)
Erp::Payments::PaymentType.create(name: 'Đơn hàng đặt mua lẻ', code: Erp::Payments::PaymentType::CODE_PURCHASE_ORDER, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true, is_receivable: true)
Erp::Payments::PaymentType.create(name: 'Công nợ khách hàng', code: Erp::Payments::PaymentType::CODE_CUSTOMER, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true, is_receivable: true)
Erp::Payments::PaymentType.create(name: 'Công nợ nhà cung cấp', code: Erp::Payments::PaymentType::CODE_SUPPLIER, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true, is_receivable: true)
Erp::Payments::PaymentType.create(name: 'Hoa hồng nhân viên', code: Erp::Payments::PaymentType::CODE_COMMISSION, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true, is_receivable: true)
Erp::Payments::PaymentType.create(name: 'Chiết khấu khách hàng', code: Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true, is_receivable: true)
Erp::Payments::PaymentType.create(name: 'Hàng bán bị trả lại', code: Erp::Payments::PaymentType::CODE_PRODUCT_RETURN, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true, is_receivable: true)

Erp::Payments::PaymentType.create(name: 'Cố định: nhà + lương', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Phát sinh: gởi hàng, văn phòng...', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Phát sinh Marketing', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Công tác phí', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Tiếp khách', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Thưởng mở account – PKD (new acc)', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Phí vận chuyển hàng', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Lãi ngân hàng', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_receivable: true)
puts '==== Payment type created ===='

# Hệ thống tài khoản kế toán
user = Erp::User.first
Erp::Payments::AccountingAccount.destroy_all
account_types = [
  {code: '121', name: 'Tiền mặt'},
  {code: '1111', name: 'Tiền mặt Việt Nam'},
  {code: '1112', name: 'Tiền mặt ngoại tệ'},
  {code: '112', name: 'Tiền mặt gửi ngân hàng'},
  {code: '1121', name: 'Ngân hàng Việt Nam'},
  {code: '1122', name: 'Ngân hàng ngoại tệ'},
  {code: '121', name: 'Chứng khoán kinh doanh'},
  {code: '128', name: 'Đầu tư nắm giữ đến ngày đáo hạn'},
  {code: '1281', name: 'Tiền gửi có kỳ hạn'},
  {code: '1288', name: 'Các khoản đầu tư khác nắm giữ đến ngày đáo hạn'},
  {code: '131', name: 'Phải thu của khách hàng'},
  {code: '133', name: 'Thuế GTGT được khấu trừ'},
  {code: '1331', name: 'Thuế GTGT được khấu trừ của hàng hóa, dịch vụ'},
  {code: '1332', name: 'Thuế GTGT được khấu trừ của TSCĐ'},
  {code: '136', name: 'Phải thu nội bộ'},
  {code: '1361', name: 'Vốn kinh doanh ở đơn vị trực thuộc'},
  {code: '1368', name: 'Phải thu nội bộ khác'},
  {code: '138', name: 'Phải thu khác'},
  {code: '1381', name: 'Tài sản thiếu chờ xử lý'},
  {code: '1386', name: 'Cầm cố, thế chấp, ký quỹ, ký cược'},
  {code: '1388', name: 'Phải thu khác'},
  {code: '141', name: 'Tạm ứng'},
  {code: '151', name: 'Hàng mua đang đi đường'},
  {code: '152', name: 'Nguyên liệu, vật liệu'},
  {code: '153', name: 'Công cụ, dụng cụ'},
  {code: '154', name: 'Chi phí sản xuất, kinh doanh dở dang'},
  {code: '155', name: 'Thành phẩm'},
  {code: '156', name: 'Hàng hóa'},
  {code: '157', name: 'Hàng gửi đi bán'},
  {code: '211', name: 'Tài sản cố định'},
  {code: '2111', name: 'TSCĐ hữu hình'},
  {code: '2112', name: 'TSCĐ thuê tài chính'},
  {code: '2113', name: 'TSCĐ vô hình'},
  {code: '214', name: 'Hao mòn tài sản cố định'},
  {code: '2141', name: 'Hao mòn TSCĐ hữu hình'},
  {code: '2142', name: 'Hao mòn TSCĐ thuê tài chính'},
  {code: '2143', name: 'Hao mòn TSCĐ vô hình'},
  {code: '2147', name: 'Hao mòn bất động sản đầu tư'},
  {code: '217', name: 'Bất động sản đầu tư'},
  {code: '228', name: 'Đầu tư góp vốn vào đơn vị khác'},
  {code: '2281', name: 'Đầu tư vào công ty liên doanh, liên kết'},
  {code: '2288', name: 'Đầu tư khác'},
  {code: '229', name: 'Dự phòng tổn thất tài sản'},
  {code: '2291', name: 'Dự phòng giảm giá chứng khoán kinh doanh'},
  {code: '2292', name: 'Dự phòng tổn thất đầu tư vào đơn vị khác'},
  {code: '2293', name: 'Dự phòng phải thu khó đòi'},
  {code: '2294', name: 'Dự phòng giảm giá hàng tồn kho'},
  {code: '241', name: 'Xây dựng cơ bản dở dang'},
  {code: '2411', name: 'Mua sắm TSCĐ'},
  {code: '2412', name: 'Xây dựng cơ bản'},
  {code: '2413', name: 'Sửa chữa lớn TSCĐ'},
  {code: '242', name: 'Chi phí trả trước'},
  {code: '331', name: 'Phải trả cho người bán'},
  {code: '333', name: 'Thuế và các khoản phải nộp Nhà nước'},
  {code: '3331', name: 'Thuế giá trị gia tăng phải nộp'},
  {code: '33311', name: 'Thuế GTGT đầu ra'},
  {code: '33312', name: 'Thuế GTGT hàng nhập khẩu'},
  {code: '3332', name: 'Thuế tiêu thụ đặc biệt'},
  {code: '3333', name: 'Thuế xuất, nhập khẩu'},
  {code: '3334', name: 'Thuế thu nhập doanh nghiệp'},
  {code: '3335', name: 'Thuế thu nhập cá nhân'},
  {code: '3336', name: 'Thuế tài nguyên'},
  {code: '3337', name: 'Thuế nhà đất, tiền thuê đất'},
  {code: '3338', name: 'Thuế bảo vệ môi trường và các loại thuế khác'},
  {code: '33381', name: 'Thuế bảo vệ môi trường'},
  {code: '33382', name: 'Các loại thuế khác'},
  {code: '3339', name: 'Phí, lệ phí và các khoản phải nộp khác'},
  {code: '334', name: 'Phải trả người lao động'},
  {code: '335', name: 'Chi phí phải trả'},
  {code: '336', name: 'Phải trả nội bộ'},
  {code: '3361', name: 'Phải trả nội bộ về vốn kinh doanh'},
  {code: '3368', name: 'Phải trả nội bộ khác'},
  {code: '338', name: 'Phải trả, phải nộp khác'},
  {code: '3381', name: 'Tài sản thừa chờ giải quyết'},
  {code: '3382', name: 'Kinh phí công đoàn'},
  {code: '3383', name: 'Bảo hiểm xã hội'},
  {code: '3384', name: 'Bảo hiểm y tế'},
  {code: '3385', name: 'Bảo hiểm thất nghiệp'},
  {code: '3386', name: 'Nhận ký quỹ, ký cược'},
  {code: '3387', name: 'Doanh thu chưa thực hiện'},
  {code: '3388', name: 'Phải trả, phải nộp khác'},
  {code: '341', name: 'Vay và nợ thuê tài chính'},
  {code: '3411', name: 'Các khoản đi vay'},
  {code: '3412', name: 'Nợ thuê tài chính'},
  {code: '352', name: 'Dự phòng phải trả'},
  {code: '3521', name: 'Dự phòng bảo hành sản phẩm hàng hóa'},
  {code: '3522', name: 'Dự phòng bảo hành công trình xây dựng'},
  {code: '3524', name: 'Dự phòng phải trả khác'},
  {code: '353', name: 'Quỹ khen thưởng phúc lợi'},
  {code: '3531', name: 'Quỹ khen thưởng'},
  {code: '3532', name: 'Quỹ phúc lợi'},
  {code: '3533', name: 'Quỹ phúc lợi đã hình thành TSCĐ'},
  {code: '3534', name: 'Quỹ thưởng ban quản lý điều hành công ty'},
  {code: '356', name: 'Quỹ phát triển khoa học và công nghệ'},
  {code: '3561', name: 'Quỹ phát triển khoa học và công nghệ'},
  {code: '3562', name: 'Quỹ phát triển khoa học và công nghệ đã hình thành TSCĐ'},
  {code: '411', name: 'Vốn đầu tư của chủ sở hữu'},
  {code: '4111', name: 'Vốn góp của chủ sở hữu'},
  {code: '4112', name: 'Thặng dư vốn cổ phần'},
  {code: '4118', name: 'Vốn khác'},
  {code: '413', name: 'Chênh lệch tỷ giá hối đoái'},
  {code: '418', name: 'Các quỹ thuộc vốn chủ sở hữu'},
  {code: '419', name: 'Cổ phiếu quỹ'},
  {code: '421', name: 'Lợi nhuận sau thuế chưa phân phối'},
  {code: '4211', name: 'Lợi nhuận sau thuế chưa phân phối năm trước'},
  {code: '4212', name: 'Lợi nhuận sau thuế chưa phân phối năm nay'},
  {code: '511', name: 'Doanh thu bán hàng và cung cấp dịch vụ'},
  {code: '5111', name: 'Doanh thu bán hàng hóa'},
  {code: '5112', name: 'Doanh thu bán thành phẩm'},
  {code: '5113', name: 'Doanh thu cung cấp dịch vụ'},
  {code: '5118', name: 'Doanh thu khác'},
  {code: '515', name: 'Doanh thu hoạt động tài chính'},
  {code: '611', name: 'Mua hàng'},
  {code: '631', name: 'Giá thành sản xuất'},
  {code: '632', name: 'Giá vốn hàng bán'},
  {code: '635', name: 'Chi phí tài chính'},
  {code: '642', name: 'Chi phí quản lý kinh doanh'},
  {code: '6421', name: 'Chi phí bán hàng'},
  {code: '6422', name: 'Chi phí quản lý doanh nghiệp'},
  {code: '711', name: 'Thu nhập khác'},
  {code: '811', name: 'Chi phí khác'},
  {code: '821', name: 'Chi phí thuế thu nhập doanh nghiệp'},
  {code: '911', name: 'Xác định kết quả kinh doanh'},
]

account_types.each do |acc|
  puts Erp::Payments::AccountingAccount.create(
    code: acc[:code],
    name: acc[:name],
    creator_id: user.id,
    status: 'active',
  ).errors.to_json
end
