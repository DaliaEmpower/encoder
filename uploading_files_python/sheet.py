import os
import pandas as pd

def generate_dataframe(directory):
    data = []
    for curso in os.listdir(directory):
        curso_path = os.path.join(directory, curso)
        if os.path.isdir(curso_path):
            for leccion in os.listdir(curso_path):
                leccion_path = os.path.join(curso_path, leccion)
                if os.path.isdir(leccion_path):
                    m3u8_files = [file for file in os.listdir(leccion_path) if file.endswith('.m3u8')]
                    if m3u8_files:
                        m3u8_file = m3u8_files[0]
                        m3u8_path = os.path.join(leccion_path, m3u8_file)
                        link_server = "http://example.com/{}".format(m3u8_file)
                        data.append([curso, leccion, m3u8_path, link_server])
    
    df = pd.DataFrame(data, columns=['Curso', 'Lección', 'ruta m3u8', 'link server'])
    return df

directory = 'hls'
df = generate_dataframe(directory)
df.head()