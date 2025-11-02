#!/bin/bash

# Setup AI integration (OpenAI, Anthropic, or both)

setup_ai() {
    local package_manager=$1
    local ai_provider=$2  # "openai", "anthropic", or "both"

    echo -e "${BLUE}Setting up AI integration...${NC}"

    # Install packages based on selection
    if [ "$ai_provider" = "openai" ] || [ "$ai_provider" = "both" ]; then
        echo -e "${BLUE}Installing OpenAI SDK...${NC}"
        if [ "$package_manager" = "pnpm" ]; then
            pnpm add openai
        elif [ "$package_manager" = "yarn" ]; then
            yarn add openai
        else
            npm install openai
        fi
        echo -e "${GREEN}✓ OpenAI SDK installed${NC}"
    fi

    if [ "$ai_provider" = "anthropic" ] || [ "$ai_provider" = "both" ]; then
        echo -e "${BLUE}Installing Anthropic SDK...${NC}"
        if [ "$package_manager" = "pnpm" ]; then
            pnpm add @anthropic-ai/sdk
        elif [ "$package_manager" = "yarn" ]; then
            yarn add @anthropic-ai/sdk
        else
            npm install @anthropic-ai/sdk
        fi
        echo -e "${GREEN}✓ Anthropic SDK installed${NC}"
    fi

    # Create lib/ai directory
    mkdir -p lib/ai

    # Create OpenAI utility if selected
    if [ "$ai_provider" = "openai" ] || [ "$ai_provider" = "both" ]; then
        cat > lib/ai/openai.ts << 'EOF'
import OpenAI from 'openai';

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Helper function for chat completions
export async function chatCompletion(
  messages: { role: 'system' | 'user' | 'assistant'; content: string }[],
  options?: {
    model?: string;
    temperature?: number;
    maxTokens?: number;
    stream?: boolean;
  }
) {
  const response = await openai.chat.completions.create({
    model: options?.model || 'gpt-4o',
    messages,
    temperature: options?.temperature || 0.7,
    max_tokens: options?.maxTokens || 1000,
    stream: options?.stream || false,
  });

  return response;
}

// Helper function for streaming responses
export async function* streamChatCompletion(
  messages: { role: 'system' | 'user' | 'assistant'; content: string }[],
  options?: {
    model?: string;
    temperature?: number;
    maxTokens?: number;
  }
) {
  const stream = await openai.chat.completions.create({
    model: options?.model || 'gpt-4o',
    messages,
    temperature: options?.temperature || 0.7,
    max_tokens: options?.maxTokens || 1000,
    stream: true,
  });

  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content || '';
    if (content) {
      yield content;
    }
  }
}

// Helper for embeddings
export async function createEmbedding(text: string) {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: text,
  });

  return response.data[0].embedding;
}

export default openai;
EOF
        echo -e "${GREEN}✓ OpenAI utilities created at lib/ai/openai.ts${NC}"
    fi

    # Create Anthropic utility if selected
    if [ "$ai_provider" = "anthropic" ] || [ "$ai_provider" = "both" ]; then
        cat > lib/ai/anthropic.ts << 'EOF'
import Anthropic from '@anthropic-ai/sdk';

// Initialize Anthropic client
const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Helper function for messages
export async function createMessage(
  messages: { role: 'user' | 'assistant'; content: string }[],
  options?: {
    model?: string;
    maxTokens?: number;
    temperature?: number;
    system?: string;
    stream?: boolean;
  }
) {
  const response = await anthropic.messages.create({
    model: options?.model || 'claude-3-5-sonnet-20241022',
    max_tokens: options?.maxTokens || 1024,
    temperature: options?.temperature || 1,
    system: options?.system,
    messages,
    stream: options?.stream || false,
  });

  return response;
}

// Helper function for streaming responses
export async function* streamMessage(
  messages: { role: 'user' | 'assistant'; content: string }[],
  options?: {
    model?: string;
    maxTokens?: number;
    temperature?: number;
    system?: string;
  }
) {
  const stream = await anthropic.messages.create({
    model: options?.model || 'claude-3-5-sonnet-20241022',
    max_tokens: options?.maxTokens || 1024,
    temperature: options?.temperature || 1,
    system: options?.system,
    messages,
    stream: true,
  });

  for await (const event of stream) {
    if (event.type === 'content_block_delta' && event.delta.type === 'text_delta') {
      yield event.delta.text;
    }
  }
}

export default anthropic;
EOF
        echo -e "${GREEN}✓ Anthropic utilities created at lib/ai/anthropic.ts${NC}"
    fi

    # Create unified AI helper
    cat > lib/ai/index.ts << 'EOF'
// Unified AI helper - use whichever provider is configured

type AIProvider = 'openai' | 'anthropic';

export function getConfiguredProvider(): AIProvider | null {
  if (process.env.OPENAI_API_KEY) return 'openai';
  if (process.env.ANTHROPIC_API_KEY) return 'anthropic';
  return null;
}

export async function generateText(
  prompt: string,
  options?: {
    provider?: AIProvider;
    systemPrompt?: string;
    temperature?: number;
    maxTokens?: number;
  }
): Promise<string> {
  const provider = options?.provider || getConfiguredProvider();

  if (!provider) {
    throw new Error('No AI provider configured. Set OPENAI_API_KEY or ANTHROPIC_API_KEY');
  }

  if (provider === 'openai') {
    const { chatCompletion } = await import('./openai');
    const messages = [];

    if (options?.systemPrompt) {
      messages.push({ role: 'system' as const, content: options.systemPrompt });
    }

    messages.push({ role: 'user' as const, content: prompt });

    const response = await chatCompletion(messages, {
      temperature: options?.temperature,
      maxTokens: options?.maxTokens,
    });

    return response.choices[0].message.content || '';
  } else {
    const { createMessage } = await import('./anthropic');
    const response = await createMessage(
      [{ role: 'user', content: prompt }],
      {
        system: options?.systemPrompt,
        temperature: options?.temperature,
        maxTokens: options?.maxTokens,
      }
    );

    return response.content[0].type === 'text' ? response.content[0].text : '';
  }
}

export async function* streamText(
  prompt: string,
  options?: {
    provider?: AIProvider;
    systemPrompt?: string;
    temperature?: number;
    maxTokens?: number;
  }
): AsyncGenerator<string, void, unknown> {
  const provider = options?.provider || getConfiguredProvider();

  if (!provider) {
    throw new Error('No AI provider configured. Set OPENAI_API_KEY or ANTHROPIC_API_KEY');
  }

  if (provider === 'openai') {
    const { streamChatCompletion } = await import('./openai');
    const messages = [];

    if (options?.systemPrompt) {
      messages.push({ role: 'system' as const, content: options.systemPrompt });
    }

    messages.push({ role: 'user' as const, content: prompt });

    for await (const chunk of streamChatCompletion(messages, {
      temperature: options?.temperature,
      maxTokens: options?.maxTokens,
    })) {
      yield chunk;
    }
  } else {
    const { streamMessage } = await import('./anthropic');
    for await (const chunk of streamMessage(
      [{ role: 'user', content: prompt }],
      {
        system: options?.systemPrompt,
        temperature: options?.temperature,
        maxTokens: options?.maxTokens,
      }
    )) {
      yield chunk;
    }
  }
}
EOF

    echo -e "${GREEN}✓ Unified AI helper created at lib/ai/index.ts${NC}"

    # Create example API route
    mkdir -p app/api/ai/chat
    cat > app/api/ai/chat/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server';
import { generateText, streamText } from '@/lib/ai';

export const runtime = 'edge'; // Use edge runtime for better performance

// POST /api/ai/chat
export async function POST(req: NextRequest) {
  try {
    const { prompt, systemPrompt, stream } = await req.json();

    if (!prompt) {
      return NextResponse.json(
        { error: 'Prompt is required' },
        { status: 400 }
      );
    }

    // Streaming response
    if (stream) {
      const encoder = new TextEncoder();
      const customReadable = new ReadableStream({
        async start(controller) {
          try {
            for await (const chunk of streamText(prompt, { systemPrompt })) {
              controller.enqueue(encoder.encode(chunk));
            }
            controller.close();
          } catch (error) {
            controller.error(error);
          }
        },
      });

      return new Response(customReadable, {
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Transfer-Encoding': 'chunked',
        },
      });
    }

    // Non-streaming response
    const response = await generateText(prompt, { systemPrompt });

    return NextResponse.json({ response });
  } catch (error: any) {
    console.error('AI API error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to generate response' },
      { status: 500 }
    );
  }
}
EOF

    echo -e "${GREEN}✓ Example API route created at app/api/ai/chat/route.ts${NC}"

    # Create example usage component
    mkdir -p components/examples
    cat > components/examples/ai-chat-example.tsx << 'EOF'
"use client"

import { useState } from 'react';

export function AIChatExample() {
  const [prompt, setPrompt] = useState('');
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setResponse('');

    try {
      const res = await fetch('/api/ai/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt,
          systemPrompt: 'You are a helpful assistant.',
          stream: false,
        }),
      });

      const data = await res.json();
      setResponse(data.response);
    } catch (error) {
      console.error('Error:', error);
      setResponse('Error generating response');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <h2 className="text-2xl font-bold mb-4">AI Chat Example</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <textarea
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          placeholder="Enter your prompt..."
          className="w-full p-3 border rounded-md min-h-[100px]"
          disabled={loading}
        />
        <button
          type="submit"
          disabled={loading || !prompt}
          className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Generating...' : 'Generate'}
        </button>
      </form>
      {response && (
        <div className="mt-6 p-4 bg-gray-100 rounded-md">
          <h3 className="font-semibold mb-2">Response:</h3>
          <p className="whitespace-pre-wrap">{response}</p>
        </div>
      )}
    </div>
  );
}
EOF

    echo -e "${GREEN}✓ Example chat component created${NC}"

    echo -e "\n${CYAN}AI Integration Setup Complete:${NC}"
    [ "$ai_provider" = "openai" ] || [ "$ai_provider" = "both" ] && echo -e "  ${GREEN}✓${NC} OpenAI SDK installed"
    [ "$ai_provider" = "anthropic" ] || [ "$ai_provider" = "both" ] && echo -e "  ${GREEN}✓${NC} Anthropic SDK installed"
    echo -e "  ${GREEN}✓${NC} AI helper utilities created"
    echo -e "  ${GREEN}✓${NC} Example API route created"
    echo -e "  ${GREEN}✓${NC} Example chat component created"
    echo -e "\n  ${YELLOW}Next steps:${NC}"
    echo -e "    1. Add your API key(s) to .env.local"
    [ "$ai_provider" = "openai" ] || [ "$ai_provider" = "both" ] && echo -e "       ${CYAN}OPENAI_API_KEY=sk-...${NC}"
    [ "$ai_provider" = "anthropic" ] || [ "$ai_provider" = "both" ] && echo -e "       ${CYAN}ANTHROPIC_API_KEY=sk-ant-...${NC}"
    echo -e "    2. Use the unified API: ${CYAN}import { generateText } from '@/lib/ai'${NC}"
    echo -e "    3. Try the example: ${CYAN}import { AIChatExample } from '@/components/examples/ai-chat-example'${NC}"
}
EOF
