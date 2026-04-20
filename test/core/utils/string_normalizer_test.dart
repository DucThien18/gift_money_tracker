import 'package:flutter_test/flutter_test.dart';
import 'package:gift_money_tracker/core/utils/string_normalizer.dart';

void main() {
  group('StringNormalizer.normalizeForSearch', () {
    test('chuỗi rỗng trả về rỗng', () {
      expect(StringNormalizer.normalizeForSearch(''), '');
    });

    test('chuyển về chữ thường', () {
      expect(StringNormalizer.normalizeForSearch('HELLO'), 'hello');
    });

    test('trim khoảng trắng đầu cuối', () {
      expect(StringNormalizer.normalizeForSearch('  hello  '), 'hello');
    });

    test('chuẩn hóa nhiều khoảng trắng liên tiếp thành một', () {
      expect(
        StringNormalizer.normalizeForSearch('hello   world'),
        'hello world',
      );
    });

    test('bỏ dấu tiếng Việt — chữ thường', () {
      expect(StringNormalizer.normalizeForSearch('nguyễn'), 'nguyen');
      expect(StringNormalizer.normalizeForSearch('văn'), 'van');
      expect(StringNormalizer.normalizeForSearch('đức'), 'duc');
      expect(StringNormalizer.normalizeForSearch('thành'), 'thanh');
      expect(StringNormalizer.normalizeForSearch('phương'), 'phuong');
    });

    test('bỏ dấu tiếng Việt — chữ hoa', () {
      expect(StringNormalizer.normalizeForSearch('NGUYỄN'), 'nguyen');
      expect(StringNormalizer.normalizeForSearch('ĐỨC'), 'duc');
    });

    test('bỏ dấu tên đầy đủ tiếng Việt', () {
      expect(
        StringNormalizer.normalizeForSearch('Nguyễn Văn A'),
        'nguyen van a',
      );
      expect(
        StringNormalizer.normalizeForSearch('Trần Thị Bích Phượng'),
        'tran thi bich phuong',
      );
    });

    test('chuỗi không có dấu giữ nguyên (sau lowercase)', () {
      expect(StringNormalizer.normalizeForSearch('hello world'), 'hello world');
    });

    test('chuỗi số không bị thay đổi', () {
      expect(StringNormalizer.normalizeForSearch('123456'), '123456');
    });

    test('kết hợp: tên tiếng Việt + khoảng trắng thừa + chữ hoa', () {
      expect(
        StringNormalizer.normalizeForSearch('  NGUYỄN   VĂN   A  '),
        'nguyen van a',
      );
    });
  });

  group('StringNormalizer.removeDiacritics', () {
    test('bỏ dấu nhưng giữ nguyên chữ hoa/thường', () {
      expect(StringNormalizer.removeDiacritics('Nguyễn'), 'Nguyen');
      expect(StringNormalizer.removeDiacritics('NGUYỄN'), 'NGUYEN');
      expect(StringNormalizer.removeDiacritics('nguyễn'), 'nguyen');
    });

    test('chuỗi không dấu giữ nguyên', () {
      expect(StringNormalizer.removeDiacritics('hello'), 'hello');
    });

    test('đ/Đ chuyển thành d/D', () {
      expect(StringNormalizer.removeDiacritics('đường'), 'duong');
      expect(StringNormalizer.removeDiacritics('Đức'), 'Duc');
    });
  });
}
