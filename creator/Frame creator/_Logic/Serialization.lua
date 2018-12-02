---------- Алгоритмы сериализации строк ----------

-- Имя
Serialization = {};


---- Реализация ----
-- из таблицы с символами собирает строку
function Serialization.bytesToString( str_bytes_table )
  local str = "";

  for i, val in ipairs(str_bytes_table) do
    str = str .. string.char(val);
  end;

  return str;
end;

-- разбирает строку и записывает коды символов в таблицу
function Serialization.stringBytes( str )
  -- разбираем строку str на символы и кидаем всё в таблицу
  local str_bytes_table = {};
  for l = 1, #str do
    str_bytes_table[l] = string.byte(str, l);
  end;

  return str_bytes_table;
end;
