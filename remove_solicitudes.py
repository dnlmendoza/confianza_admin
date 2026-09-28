import sys, re

def process_vista(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Remove pendingCount and notifications logic
    content = re.sub(
        r'final pendingCount = .*?;[\s]*final notifications = .*?\][\s]*: <String>\[\];',
        '',
        content,
        flags=re.DOTALL
    )
    
    content = content.replace("notifications: notifications,", "notifications: const [],")
    
    # 2. Remove tab "Solicitudes de Acceso"
    tab_regex = r'Expanded\(\s*child:\s*_buildTableTabItem\(\s*"Solicitudes de Acceso".*?\),\s*\),'
    content = re.sub(tab_regex, '', content, flags=re.DOTALL)
    
    with open(filepath, 'w') as f:
        f.write(content)

def process_bento(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Desktop
    card_regex = r'Expanded\(\s*child:\s*_buildBentoStatCard\(\s*title: "Solicitudes".*?\),\s*\),'
    content = re.sub(card_regex, '', content, flags=re.DOTALL)
    
    # Mobile
    mobile_card_regex = r'_buildBentoStatCard\(\s*title: "Solicitudes".*?\),'
    content = re.sub(mobile_card_regex, '', content, flags=re.DOTALL)
    
    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == "__main__":
    process_vista('/Users/dnl/Documents/Dev_Confianza/confianza_admin/lib/modulos/usuarios/vista_usuarios.dart')
    process_bento('/Users/dnl/Documents/Dev_Confianza/confianza_admin/lib/modulos/usuarios/widgets/bento_stats_grid.dart')
