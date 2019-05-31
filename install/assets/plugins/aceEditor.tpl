/**
 * Ace Editor
 *
 * @category	plugin
 * @version	0.1
 * @internal	@properties &theme=Theme;list;ambiance,chaos,chrome,clouds,clouds_midnight,cobalt,crimson_editor,dawn,dracula,dreamweaver,eclipse,github,gob,gruvbox,idle_fingers,iplastic,katzenmilch,kr_theme,kuroir,merbivore,merbivore_soft,mono_industrial,monokai,pastel_on_dark,solarized_dark,solarized_light,sqlserver,terminal,textmate,tomorrow,tomorrow_night,tomorrow_night_blue,tomorrow_night_bright,tomorrow_night_eighties,twilight,vibrant_ink,xcode;monokai &minLines=Min editor height in lines;int;30 &maxLines=Max editor height in lines;int;200 &wordWrap=Word wrap nabled;list;true,false;false &htmlMode=Html mode;list;html,jade;html
 * @internal	@events OnChunkFormRender,OnRichTextEditorInit,OnRichTextEditorRegister,OnSnipFormRender
 * @internal	@disabled 0
 * 
 * @author	https://github.com/disaipe
 */

if (!defined('MODX_BASE_PATH')) { die('What are you doing? Get out of here!'); }

global $content;

$e = &$modx->event;
$label = 'AceEditor';

$options = [
	'theme' => $theme,
	'minLines' => $minLines ? $minLines : 20,
	'maxLines' => $maxLines ? $maxLines : 'Infinity',
	'wordWrap' => $wordWrap ? $wordWrap : 'false',
	'htmlMode' => $htmlMode ? $htmlMode : 'html'
];

if (!function_exists('init_aceEditor')) {
	function init_aceEditor($e) {
		if (defined('INIT_ACEEDITOR'))
			return;
		
		define('INIT_ACEEDITOR', 1);
		$output = "
			<script src='https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.4/ace.js'></script>
			<script>var codeElems = {}; var editors = {};</script>
		";
		$e->addOutput($output);
	}
}

if (!function_exists('add_aceEditor')) {
	function add_aceEditor($e, $mode, $elements, $options) {
		init_aceEditor($e);
		
		$output = "";
		foreach ($elements as $elem) {
			$output .= "
				<script>	
					codeElems['$elem'] = document.getElementById('$elem');
					codeElems['$elem'].style.display = 'none';

					var editorEl = document.createElement('div');
					editorEl.id = '$elem-editor';
					editorEl.innerHTML = codeElems['$elem'].value.replace('<', '&lt');
					codeElems['$elem'].parentNode.appendChild(editorEl);

					editors['$elem'] = ace.edit('$elem-editor');
					editors['$elem'].setOptions({
						wrap: $options[wordWrap],
						minLines: $options[minLines],
						maxLines: $options[maxLines],
					});

					editors['$elem'].setTheme('ace/theme/$options[theme]');
					editors['$elem'].session.setMode('ace/mode/$mode');
					editors['$elem'].session.\$mode.\$highlightRules.addRules(
						{
							'start': [{ token:'tag', regex: '{{', next: 'chunk' }],
							'chunk': [{ token:'tag', regex: '}}', next: 'start' }, { defaultToken: 'tag' }]
						}, 'modx-'
					);
					editors['$elem'].session.on('change', function() {
						codeElems['$elem'].innerHTML = editors['$elem'].session.getValue().replace('<', '&lt');
					});
					console.log(editors);
				</script>	
			";
		}
		
		$e->addOutput($output);
	}
}

switch ($e->name) {
	case 'OnRichTextEditorRegister':
		$e->output($label);
		return;
		break;
		
	case 'OnRichTextEditorInit':
		if($editor == $label) {	
			$contentType = $content['contentType'] ? $content['contentType'] : $e->params['contentType'];

			switch ($contentType) {
				case 'text/html':
					$mode = $options['htmlMode'];
					break;
				case 'text/plane':
					$mode = 'plain_text';
					break;
				case 'text/javascript':
					$mode = 'javascript';
					break;
				case 'application/json':
					$mode = 'json';
					break;
				case 'application/x-httpd-php':
					$mode = 'php';
					break;
				default:
					$mode = 'plain_text';
					break;
			}
				
			$textareaName = $e->params['elements'][0];
			$elements = [$textareaName];
				
			add_aceEditor($e, $mode, $elements, $options);
			return;
		}
		break;
		
	case 'OnSnipFormRender':
		add_aceEditor($e, 'php', ['post'], $options);
		break;
		
	case 'OnChunkFormRender':
		add_aceEditor($e, $options['htmlMode'], ['post'], $options);
		return;
		break;
		
	default:
		return;
		break;
}