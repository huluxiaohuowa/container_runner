from openai import OpenAI
import traceback


client = OpenAI(
    base_url="http://127.0.0.1:8000/v1",
    api_key="dummy_key"  # 使用虚拟的API Key
)


response = client.chat.completions.create(
    model="default-model",
    messages=[{"role": "user", "content": "给我讲个鬼故事"}],
    stream=True
)
for chunk in response:
    content = chunk.choices[0].delta.content
    if content:
        print(content, end='', flush=True)
print()