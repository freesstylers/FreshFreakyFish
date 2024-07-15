extends OptionButton

var langs : PackedStringArray

func _ready():
	langs = TranslationServer.get_loaded_locales()
	for locale in langs:
		match locale:	
			"ca_ES":
				add_item("Valencià")
			"ca":
				add_item("Catalá")
			"es":
				add_item("Castellano")
			"eu":
				add_item("Euskera")
			"gl":
				add_item("Galego")	
			"ast":
				add_item("Asturianu")	
			"la":
				add_item("Latīnum")	
			"ang":
				add_item("Andalûh")
			"en":
				add_item(TranslationServer.get_locale_name(locale))	
	
	select(langs.find("es"))

func _on_item_selected(index):
	TranslationServer.set_locale(langs[index])
