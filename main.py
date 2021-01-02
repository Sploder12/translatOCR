from googletrans import Translator

translator = Translator()
result = translator.translate("Me gusta los huevos")
print(result.text)